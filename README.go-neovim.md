# Go Development Setup with Native Neovim (0-Plugin) & Nix Flakes

This document describes a zero-plugin Neovim configuration for Go development, paired with a Nix Flake and `direnv` setup for reproducible dependencies (`go`, `gopls`, `gofumpt`, `golangci-lint`, `delve`).

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Architecture](#project-architecture)
- [Quick Start](#quick-start)
- [Nix Environment (`flake.nix` & `.envrc`)](#nix-environment-flakenix--envrc)
- [Neovim Configuration (`init.lua`)](#neovim-configuration-initlua)
- [Keybindings Reference](#keybindings-reference)
- [Workflow Guide](#workflow-guide)
  - [Auto-Completion](#auto-completion)
  - [Formatting & Code Quality](#formatting--code-quality)
  - [Diagnostics](#diagnostics)
  - [Compile, Run & Test](#compile-run--test)
  - [Debugging with Delve](#debugging-with-delve)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

Modern Neovim includes a built-in LSP client, diagnostic engine, auto-completion support (`omnifunc`), and build interface (`:make`). By leveraging these built-in capabilities alongside Nix Flakes:

- **Zero Plugin Overhead**: Fast startup times, no plugin managers (`lazy.nvim`, `packer`), no floating abstraction layers.
- **Hermetic Dependencies**: The compiler (`go`), language server (`gopls`), strictly enforcing formatter (`gofumpt`), and debugger (`delve`) are isolated per-project using Nix.
- **Automated Environment**: `direnv` automatically activates the environment whenever you navigate into the directory or open Neovim.

### What you give up

Being honest about the trade-off, since it shapes the workflow below:

| Capability | Plugin ecosystem | This setup |
| --- | --- | --- |
| Completion popup | `nvim-cmp`, fuzzy, multi-source | `omnifunc` (`<C-x><C-o>`), or `vim.lsp.completion.enable` autotrigger on 0.11+ |
| Fuzzy finder | `telescope.nvim` | `:find`, `:grep`, quickfix list |
| Debugger UI | `nvim-dap` + `nvim-dap-ui` | `delve` TUI in a `:terminal` split |
| Syntax objects | `nvim-treesitter` | Bundled treesitter parsers on 0.9+ (`vim.treesitter.start()`) |

Everything Go-specific — completion, diagnostics, formatting, imports, rename, references — is served by `gopls` and needs no plugin at all.

---

## ⚙️ Prerequisites

1. **Neovim** (v0.8+ for native LSP; v0.11+ unlocks autotriggered completion — see notes inline).
2. **Nix** with Flakes enabled.
3. **direnv** installed and hooked into your shell (e.g., `bash`, `zsh`, or `fish`).

### Enabling Nix Flakes & `direnv` Shell Hook

If not already configured in your shell/system:

```bash
# Ensure experimental features are active in ~/.config/nix/nix.conf
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Hook direnv into Zsh (add to ~/.zshrc)
eval "$(direnv hook zsh)"

# Hook direnv into Bash (add to ~/.bashrc)
eval "$(direnv hook bash)"

# Hook direnv into Fish (add to ~/.config/fish/config.fish)
direnv hook fish | source
```

Verify:

```bash
nvim --version | head -1
nix flake --version
direnv --version
```

---

## 🏗 Project Architecture

```
my-go-project/
├── .envrc              # direnv: activates the flake devShell
├── .gitignore          # ignores .direnv/ and build output
├── flake.nix           # pins go, gopls, gofumpt, golangci-lint, delve
├── flake.lock          # exact input revisions (commit this)
├── go.mod
├── go.sum
├── main.go
└── internal/
    └── ...
```

Neovim config lives outside the project, in the usual location:

```
~/.config/nvim/
└── init.lua            # the entire configuration — one file, no plugin dir
```

The two halves are deliberately independent: `init.lua` never hardcodes a toolchain path, it just calls `gopls`, `go`, and `golangci-lint` as they appear on `$PATH`. `direnv` is what puts the project's pinned versions there. Open Neovim from inside the project directory and it picks up that project's Go version; open it elsewhere and it picks up whatever is on the ambient `$PATH`.

---

## 🚀 Quick Start

```bash
# 1. Scaffold the project
mkdir my-go-project && cd my-go-project
go mod init example.com/my-go-project

# 2. Drop in flake.nix and .envrc (contents in the next section)

# 3. Allow direnv to load the environment
direnv allow

# 4. Confirm the pinned toolchain is live
which go gopls gofumpt golangci-lint dlv
go version

# 5. Open Neovim — gopls attaches on the first Go buffer
nvim main.go
```

Check that the language server actually attached:

```vim
:checkhealth vim.lsp
:lua =vim.lsp.get_clients({ bufnr = 0 })[1].name
```

---

## ❄️ Nix Environment (`flake.nix` & `.envrc`)

### `flake.nix`

```nix
{
  description = "Go development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go            # compiler + toolchain
            gopls         # language server
            gofumpt       # stricter gofmt
            golangci-lint # aggregate linter
            delve         # debugger (provides `dlv`)
            gotools       # goimports, stringer, etc.
          ];

          shellHook = ''
            # Keep module/build caches inside the project so they are
            # disposable and never leak between projects.
            export GOPATH="$PWD/.direnv/go"
            export GOBIN="$GOPATH/bin"
            export PATH="$GOBIN:$PATH"

            # Refuse to silently download a different Go than the pinned one.
            export GOTOOLCHAIN=local

            echo "Go dev shell — $(go version)"
          '';
        };
      });
    };
}
```

`GOTOOLCHAIN=local` matters more than it looks. Since Go 1.21, a `go` directive in `go.mod` that is newer than the installed toolchain makes the `go` command download and run a *different* toolchain, quietly defeating the point of pinning it in Nix. `local` turns that into an error instead.

### `.envrc`

```bash
use flake
```

That single line is all the project needs. Install [`nix-direnv`](https://github.com/nix-community/nix-direnv) once, globally, and `use flake` becomes both fast and garbage-collection-safe:

```bash
nix profile install nixpkgs#nix-direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
```

Without `nix-direnv`, every `cd` into the project triggers a full flake evaluation, and the dev shell's dependencies can be collected by `nix store gc` while you are still using them. Upstream also documents a per-project `source_url` variant pinned to a release hash — take that snippet from the `nix-direnv` README rather than copying a hash from here, since it changes with every release.

### `.gitignore`

```gitignore
# direnv + Nix
.direnv/
result

# Go build output
/bin/
*.test
```

Commit `flake.lock`. That file *is* the reproducibility guarantee; without it `nixos-unstable` will drift under you.

### Updating the toolchain

```bash
nix flake update          # bump all inputs
nix flake update nixpkgs  # bump just nixpkgs
direnv reload             # re-enter the shell with the new versions
```

---

## 📝 Neovim Configuration (`init.lua`)

The whole configuration follows. It is presented in sections; concatenate them into a single `~/.config/nvim/init.lua`.

### 1. Options

```lua
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"          -- stop the diagnostic gutter from shifting text
vim.opt.updatetime = 250            -- faster CursorHold for diagnostic hovers
vim.opt.termguicolors = true

-- Go uses tabs. Do not fight it.
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Completion behaves sanely: always show a menu, never auto-insert.
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess:append("c")       -- silence "match 1 of 3" spam

-- `:find` and `gf` as a poor man's file finder.
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildoptions = "pum"
```

### 2. Treesitter highlighting (Neovim 0.9+, still zero plugins)

Neovim ships treesitter itself; only the Go *parser* is external. If you would rather not vendor a parser, skip this block — the bundled regex syntax for Go is perfectly usable.

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
```

### 3. Starting `gopls`

```lua
local function go_root(fname)
  local found = vim.fs.find({ "go.work", "go.mod", ".git" }, {
    path = vim.fs.dirname(fname),
    upward = true,
  })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function(args)
    if vim.fn.executable("gopls") == 0 then
      vim.notify("gopls not on $PATH — is direnv active?", vim.log.levels.WARN)
      return
    end

    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      root_dir = go_root(vim.api.nvim_buf_get_name(args.buf)),
      settings = {
        gopls = {
          -- Route formatting through gofumpt so `vim.lsp.buf.format()`
          -- applies the stricter rules. No second formatter process needed.
          gofumpt = true,
          staticcheck = true,
          usePlaceholders = true,
          completeUnimported = true,
          analyses = {
            unusedparams = true,
            unusedwrite = true,
            nilness = true,
            shadow = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    }, { bufnr = args.buf })
  end,
})
```

`vim.lsp.start` reuses an existing client when `name` and `root_dir` match, so opening fifty files in one module still spawns exactly one `gopls`.

> On Neovim 0.11+ you can instead write `vim.lsp.config("gopls", { … })` plus `vim.lsp.enable("gopls")` and drop the autocmd entirely. The autocmd form above works on every version from 0.8 up, which is why it is the default here.

### 4. Buffer-local keymaps on attach

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    -- Completion source for <C-x><C-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gr", vim.lsp.buf.references, "List references")
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
    map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
    map("<leader>f", function() vim.lsp.buf.format({ async = false }) end, "Format buffer")

    vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help,
      { buffer = bufnr, silent = true, desc = "Signature help" })

    -- Inlay hints (Neovim 0.10+).
    -- Note: 0.10.0 shipped `enable(bufnr, enable)` and 0.10.1 flipped it to
    -- `enable(enable, filter)`. The form below is the current one.
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      local hints_on = false
      map("<leader>th", function()
        hints_on = not hints_on
        vim.lsp.inlay_hint.enable(hints_on, { bufnr = bufnr })
      end, "Toggle inlay hints")
    end

    -- Autotriggered completion (Neovim 0.11+). Falls back to manual <C-x><C-o>.
    if vim.lsp.completion and vim.lsp.completion.enable then
      vim.lsp.completion.enable(true, args.data.client_id, bufnr, { autotrigger = true })
    end
  end,
})
```

### 5. Format + organize imports on save

`gofumpt = true` in the `gopls` settings covers formatting. Import management is a separate code action, so it needs a small synchronous helper:

```lua
local function organize_imports(bufnr, timeout_ms)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local get = vim.lsp.get_clients or vim.lsp.get_active_clients
  local client = get({ bufnr = bufnr, name = "gopls" })[1]
  if not client then return end

  local enc = client.offset_encoding or "utf-16"
  local params = vim.lsp.util.make_range_params(0, enc)
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }

  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction",
    params, timeout_ms or 1000)

  for _, response in pairs(responses or {}) do
    for _, action in pairs(response.result or {}) do
      if action.edit then
        -- Deprecated but still present as of 0.11; there is no public
        -- replacement yet, so this is the supported path.
        vim.lsp.util.apply_workspace_edit(action.edit, enc)
      elseif type(action.command) == "table" then
        if client.exec_cmd then
          client:exec_cmd(action.command, { bufnr = bufnr })   -- 0.11+
        else
          client.request("workspace/executeCommand", action.command, nil, bufnr)
        end
      end
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go" },
  callback = function(args)
    organize_imports(args.buf, 1000)
    vim.lsp.buf.format({ bufnr = args.buf, async = false })
  end,
})
```

The ordering is intentional: organize imports first (it may rewrite the import block), then format the result. Both are synchronous, because an async format racing `:w` writes stale bytes to disk.

### 6. Diagnostics

```lua
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,   -- do not shout while typing
  severity_sort = true,
  float = { border = "rounded", source = true },
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Jump maps. Neovim 0.11 replaced goto_prev/goto_next with vim.diagnostic.jump.
if vim.diagnostic.jump then
  vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
  vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)
else
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev({ float = true }) end)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next({ float = true }) end)
end
```

### 7. Build, test and lint via `:make`

```lua
local function set_make(cmd, errorformat)
  vim.bo.makeprg = cmd
  if errorformat then vim.bo.errorformat = errorformat end
end

-- Go's own output: "file.go:12:5: message", plus test failure frames.
-- Spaces are NOT backslash-escaped here: escaping is a `:set` command-line
-- requirement, and this value is assigned directly. `%*\s` keeps its backslash
-- because that one is a Vim regex atom, not an escaped space.
local go_efm = table.concat({
  "%-G# %.%#",                -- drop "# package" header lines
  "%A%f:%l:%c: %m",           -- go build / go vet
  "%A%f:%l: %m",
  "%C%*\\s%m",                -- indented continuation (go test failure bodies)
  "%-G%.%#",                  -- discard everything else
}, ",")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    set_make("go build ./...", go_efm)

    local function run(cmd)
      return function()
        set_make(cmd, go_efm)
        vim.cmd("silent make!")
        vim.cmd("cwindow")
      end
    end

    vim.keymap.set("n", "<leader>bb", run("go build ./..."), { buffer = true, desc = "go build" })
    vim.keymap.set("n", "<leader>bv", run("go vet ./..."), { buffer = true, desc = "go vet" })
    vim.keymap.set("n", "<leader>tt", run("go test ./..."), { buffer = true, desc = "go test all" })
    vim.keymap.set("n", "<leader>tf", function()
      run("go test ./" .. vim.fn.expand("%:h"))()
    end, { buffer = true, desc = "go test this package" })

    -- golangci-lint prints "path:line:col: message (linter)"
    vim.keymap.set("n", "<leader>tl", function()
      set_make("golangci-lint run", "%f:%l:%c: %m,%f:%l: %m")
      vim.cmd("silent make!")
      vim.cmd("cwindow")
    end, { buffer = true, desc = "golangci-lint" })

    -- Run the current file / module in a terminal split.
    vim.keymap.set("n", "<leader>rr", function()
      vim.cmd("botright split | resize 15 | terminal go run ./...")
    end, { buffer = true, desc = "go run" })
  end,
})

-- `:compiler go` loads Neovim's bundled Go compiler plugin and sets a similar
-- makeprg/errorformat pair. Use it instead of the explicit values above if you
-- prefer whatever ships with your Neovim version.

vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
```

### 8. Delve in a terminal split

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local function dlv(args)
      return function()
        vim.cmd("botright split | resize 20 | terminal dlv " .. args)
        vim.cmd("startinsert")
      end
    end
    vim.keymap.set("n", "<leader>dd", dlv("debug ."), { buffer = true, desc = "dlv debug" })
    vim.keymap.set("n", "<leader>dt", function()
      dlv("test ./" .. vim.fn.expand("%:h"))()
    end, { buffer = true, desc = "dlv test package" })
  end,
})

-- Escape out of terminal mode without mashing <C-\><C-n>
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]])
```

---

## ⌨️ Keybindings Reference

Leader is `<Space>`.

### LSP (active in any buffer with `gopls` attached)

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `gr` | List references (quickfix) |
| `K` | Hover documentation |
| `<C-s>` (insert) | Signature help |
| `<leader>rn` | Rename symbol across the workspace |
| `<leader>ca` | Code action (fill struct, extract, add tags…) |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>f` | Format buffer now |
| `<leader>th` | Toggle inlay hints |

### Completion (built-in insert-mode commands)

| Key | Action |
| --- | --- |
| `<C-x><C-o>` | Omni completion — the `gopls` source |
| `<C-x><C-f>` | Filename completion |
| `<C-n>` / `<C-p>` | Keyword completion from open buffers |
| `<C-y>` | Accept the selected item |
| `<C-e>` | Dismiss the menu |

### Diagnostic navigation

| Key | Action |
| --- | --- |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>e` | Show diagnostics for the current line in a float |
| `<leader>q` | Send buffer diagnostics to the location list |

### Build, test, lint

| Key | Action |
| --- | --- |
| `<leader>bb` | `go build ./...` |
| `<leader>bv` | `go vet ./...` |
| `<leader>tt` | `go test ./...` |
| `<leader>tf` | `go test` on the current file's package |
| `<leader>tl` | `golangci-lint run` |
| `<leader>rr` | `go run ./...` in a terminal split |
| `]q` / `[q` | Next / previous quickfix entry |
| `<leader>co` / `<leader>cc` | Open / close the quickfix window |

### Debug

| Key | Action |
| --- | --- |
| `<leader>dd` | `dlv debug .` in a terminal split |
| `<leader>dt` | `dlv test` on the current package |
| `<Esc><Esc>` | Leave terminal mode |

---

## 🔄 Workflow Guide

### Auto-Completion

There is no completion plugin, and on Neovim 0.11+ there does not need to be. `vim.lsp.completion.enable(…, { autotrigger = true })` in the `LspAttach` handler makes `gopls` push candidates as you type, rendered in the standard `pum`. Navigate with `<C-n>` / `<C-p>`, accept with `<C-y>`.

On 0.8–0.10, completion is manual: type a prefix and press `<C-x><C-o>`. In practice this is a smaller adjustment than it sounds, because `gopls` sorts well enough that the first candidate is usually right.

Two settings do most of the work:

- `completeUnimported = true` — offers symbols from packages you have not imported yet, and adds the import when you accept.
- `usePlaceholders = true` — expands function calls with parameter placeholders. Jump between them with `<Tab>` on 0.11+ (`vim.snippet.jump`); on older versions the placeholders are inserted as plain text.

`completeopt = { "menuone", "noselect", "noinsert" }` is what keeps this pleasant: the menu appears even for a single match, and nothing is committed to the buffer until you explicitly press `<C-y>`. Without `noinsert`, `gopls` re-ranking mid-keystroke will rewrite text under your cursor.

### Formatting & Code Quality

Formatting is `gofumpt`, reached through `gopls` rather than by shelling out. Setting `gofumpt = true` in the server settings means `vim.lsp.buf.format()` — and therefore the `BufWritePre` autocmd — applies the stricter ruleset. One process, one code path, no race between an external formatter and the language server's view of the file.

Every save does two things, in this order:

1. `source.organizeImports` — adds what you used, removes what you stopped using, groups stdlib separately from third-party.
2. `textDocument/formatting` — `gofumpt` over the whole buffer.

If a save ever appears to do nothing, the cause is almost always that the file does not parse. `gopls` will not format a buffer with syntax errors; fix the parse error and save again.

For a whole-tree pass outside the editor:

```bash
gofumpt -l -w .          # list and rewrite every file
golangci-lint run        # the aggregate linter
golangci-lint run --fix  # apply the autofixable subset
```

The `<leader>tl` mapping relies on `golangci-lint`'s default text output, `path:line:col: message (linter)`, which the quickfix `errorformat` above parses. If you pin an explicit output format, check `golangci-lint --version` first — the v1 `--out-format=…` flag was replaced by `--output.<format>.path=…` in v2, so a v1 invocation fails outright on v2.

`staticcheck = true` plus the `analyses` block means a large share of what `golangci-lint` would report already shows up as you type — `nilness` catches impossible nil branches, `unusedparams` and `unusedwrite` catch dead code, `shadow` catches accidental `:=` shadowing in `if err :=` chains. Run the full linter before pushing; rely on inline diagnostics while writing.

### Diagnostics

`gopls` publishes diagnostics as you edit; `vim.diagnostic` renders them. `update_in_insert = false` is deliberate — half-typed code is invalid by definition, and diagnosing it produces noise that trains you to ignore the gutter.

Three ways to consume them, in increasing order of scope:

```vim
" 1. Just this line
<leader>e

" 2. This buffer, as a navigable list
<leader>q
:lopen

" 3. The whole project, compiler-authoritative
<leader>bb   " :make → quickfix
```

The distinction matters: `gopls` diagnostics cover the files it has loaded, while `go build ./...` covers the entire module including packages you have never opened. Trust the quickfix list over the gutter when the two disagree.

To inspect what the server is actually saying:

```vim
:lua =vim.diagnostic.get(0)
:lua vim.cmd("edit " .. vim.lsp.get_log_path())
```

### Compile, Run & Test

`:make` is Vim's build interface and it predates every plugin that wraps it. `makeprg` is set per-filetype to `go build ./...`, and `errorformat` teaches the quickfix parser Go's `file:line:col: message` shape plus the indented continuation lines that `go test` emits for failures.

The loop is:

```vim
<leader>tt      " run the tests
]q              " jump to the first failure — cursor lands on the failing line
[q  ]q          " walk the rest
<leader>cc      " close the list when green
```

`silent make!` is used rather than `make`: the bang keeps the cursor from jumping to the first error automatically, and `silent` suppresses the command output so only the quickfix window reacts. `cwindow` then opens the list only if there is something in it — a green test run leaves the layout untouched.

For a single test, drive the CLI directly and keep the output visible:

```vim
:botright split | terminal go test -run TestParseConfig -v ./internal/config
```

Coverage, still without a plugin:

```bash
go test -coverprofile=cover.out ./...
go tool cover -html=cover.out       # opens in your browser
```

### Debugging with Delve

Neovim has no built-in DAP client, so this is the one place where the zero-plugin constraint costs something real: no breakpoint gutter, no variable-inspection pane. What you get instead is `delve`'s own TUI in a terminal split, which is a complete debugger:

```
<leader>dd      " dlv debug .
<leader>dt      " dlv test ./<current package>
```

Inside the `dlv` prompt:

| Command | Action |
| --- | --- |
| `b main.go:42` | Breakpoint at a line |
| `b main.parseConfig` | Breakpoint at a function |
| `c` | Continue |
| `n` / `s` / `so` | Next / step in / step out |
| `p expr` | Print an expression |
| `locals` / `args` | Show locals / arguments |
| `bt` | Backtrace |
| `goroutines` | List goroutines |
| `q` | Quit |

To attach to an already-running process, or to debug across a network:

```bash
dlv attach $(pgrep myservice)
dlv debug --headless --listen=:2345 --api-version=2 .
```

If you find yourself debugging daily, this is the honest place to break the zero-plugin rule and add `nvim-dap`. For occasional use, the TUI is fine.

---

## 🔧 Troubleshooting

**`gopls` does not attach.** Confirm it is on `$PATH` inside the buffer's environment — `:!which gopls`. If that comes back empty, `direnv` was not active when Neovim launched. `direnv` exports into the *shell*, so Neovim only inherits it if you started Neovim from an allowed directory. Quit, `cd` into the project, `direnv allow`, and reopen.

**Completion offers nothing.** Check `:verbose set omnifunc?` — it should read `v:lua.vim.lsp.omnifunc`. If it is empty, `LspAttach` never fired, which is the previous problem.

**Save does not format.** The buffer does not parse. Look for the syntax error with `<leader>e`, or run `gofumpt -l .` in a terminal to see whether the file is rejected outside the editor too.

**Wrong Go version.** `go version` inside the shell should match what the flake pins. A mismatch means `GOTOOLCHAIN` let the `go` command fetch a newer toolchain because `go.mod` asked for one. `export GOTOOLCHAIN=local` makes that an error instead of a silent substitution; then either lower the `go` directive in `go.mod` or bump `nixpkgs`.

**`gopls` is slow or stale in a large module.** Restart it rather than restarting Neovim:

```vim
:lua vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }))
:edit
```

**`direnv` re-evaluates the flake on every `cd`.** Install `nix-direnv` (see the `.envrc` variant above). Without it, every directory entry is a full flake evaluation.

**Diagnostics disagree with the compiler.** `gopls` only sees loaded packages; `go build ./...` sees the module. The quickfix list wins.

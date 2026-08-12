# Go Development Setup with Native Neovim (0-Plugin) & Nix Flakes

This repository provides a zero-plugin Neovim configuration for Go development, paired with a Nix Flake and `direnv` setup for reproducible dependencies (`go`, `gopls`, `gofumpt`, `golangci-lint`, `delve`).

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
- [Version & Correctness Notes](#version--correctness-notes)

---

## 🎯 Overview

Modern Neovim includes a built-in LSP client, diagnostic engine, auto-completion support (`omnifunc`), and build interface (`:make`). By leveraging these built-in capabilities alongside Nix Flakes:

- **Zero Plugin Overhead**: Fast startup times, no plugin managers (`lazy.nvim`, `packer`), no floating abstraction layers.
- **Hermetic Dependencies**: The compiler (`go`), language server (`gopls`), strictly enforcing formatter (`gofumpt`), and debugger (`delve`) are isolated per-project using Nix.
- **Automated Environment**: `direnv` automatically activates the environment whenever you navigate into the directory or open Neovim.

---

## ⚙️ Prerequisites

1. **Neovim** (v0.8+ recommended for native LSP capabilities).
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

---

## 📂 Project Architecture

Place these files in your project directory or Neovim configuration directory:

```text
.
├── flake.nix       # Nix Flake defining Go toolchain & LSP tools
├── .envrc          # direnv integration file
├── init.lua        # Zero-plugin Neovim configuration
└── README.md       # Project setup documentation
```

---

## 🚀 Quick Start

1. Clone or navigate to your Go repository.
2. Ensure `flake.nix`, `.envrc`, and `init.lua` are present in the project root (or link `init.lua` to `~/.config/nvim/init.lua`).
3. Allow `direnv`:

```bash
direnv allow
```

4. Launch Neovim:

```bash
nvim main.go
```

The Nix environment will automatically load, exposing `gopls` and `go` directly to Neovim.

---

## 🛠 Nix Environment (`flake.nix` & `.envrc`)

### `flake.nix`

```nix
{
  description = "Go development environment with gopls and LSP tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Core Go toolchain & Language Server
              go
              gopls
              # Development & Code Quality Tools
              gotools        # goimports, godoc, callgraph
              gofumpt        # Stricter gofmt formatting
              golangci-lint  # Fast multi-linter
              delve          # Go debugger
            ];
            shellHook = ''
              export GOPATH="$HOME/go"
              export PATH="$GOPATH/bin:$PATH"
              echo "Go $(go version | cut -d' ' -f3) development environment ready."
            '';
          };
        }
      );
    };
}
```

### `.envrc`

```bash
use flake
```

---

## ⚙️ Neovim Configuration (`init.lua`)

Place this in `~/.config/nvim/init.lua` or your project root:

```lua
-- ============================================================================
-- ZERO-PLUGIN NEOVIM SETUP FOR GO DEVELOPMENT
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. General & UI Settings
-- ----------------------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

-- Configure built-in auto-completion menu
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Enable native filetype detection and syntax highlighting
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- ----------------------------------------------------------------------------
-- 2. Native LSP Setup (gopls)
-- ----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function(args)
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      root_dir = vim.fs.root(args.buf, { "go.work", "go.mod", ".git" }),
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })
  end,
})

-- ----------------------------------------------------------------------------
-- 3. Autocomplete, Formatting & LSP Keybindings
-- ----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf, silent = true }

    -- Enable LSP completion engine for the buffer
    vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Autocomplete shortcut: Press Ctrl+Space in insert mode
    vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", opts)

    -- Navigation & Code Intelligence
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

    -- Diagnostics / Code Verification
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist, opts)

    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = buf,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

-- ----------------------------------------------------------------------------
-- 4. Compile, Run & Test DX
-- ----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    -- Set compiler build command for `:make`
    vim.bo.makeprg = "go build ./..."

    local opts = { buffer = true, silent = true }

    -- <leader>gb : Compile project (loads compilation errors into Quickfix list)
    vim.keymap.set("n", "<leader>gb", "<cmd>make<CR>", opts)

    -- <leader>gr : Run current main package in a split terminal
    vim.keymap.set("n", "<leader>gr", "<cmd>split | terminal go run .<CR>i", opts)

    -- <leader>gt : Run unit tests in a split terminal
    vim.keymap.set("n", "<leader>gt", "<cmd>split | terminal go test -v ./...<CR>i", opts)
  end,
})
```

---

## 🎹 Keybindings Reference

### LSP & Intelligence

| Mode | Shortcut | Action | Description |
| --- | --- | --- | --- |
| Insert | `<C-Space>` | Omnifunc Trigger | Triggers LSP autocompletion popup |
| Normal | `gd` | Go to Definition | Jump to symbol declaration |
| Normal | `K` | Hover Doc | View signature, docstring, and type info |
| Normal | `gi` | Go to Implementation | Jump to interface implementations |
| Normal | `gr` | Find References | Find all usages across the codebase |
| Normal | `<leader>rn` | Rename Symbol | Smart refactoring across files |
| Normal | `<leader>ca` | Code Actions | Apply quick fixes or import additions |

### Diagnostics & Code Verification

| Mode | Shortcut | Action | Description |
| --- | --- | --- | --- |
| Normal | `[d` | Previous Diagnostic | Jump to previous warning/error |
| Normal | `]d` | Next Diagnostic | Jump to next warning/error |
| Normal | `<leader>e` | Float Diagnostic | Show full diagnostic message in popup |
| Normal | `<leader>q` | Quickfix Diagnostics | Populate quickfix list with all buffer errors |

### Build, Run & Test DX

| Mode | Shortcut | Command Executed | Description |
| --- | --- | --- | --- |
| Normal | `<leader>gb` | `:make` (`go build ./...`) | Build codebase and load errors into quickfix |
| Normal | `<leader>gr` | `:split \| terminal go run .` | Run current package in split terminal |
| Normal | `<leader>gt` | `:split \| terminal go test -v ./...` | Execute verbose unit tests in split terminal |

---

## 💡 Workflow Guide

### Auto-Completion

When writing Go code in Insert Mode, press `<C-Space>` (or `<C-x><C-o>`) to trigger the native completion menu. Use `<C-n>` and `<C-p>` to cycle through completion items and `<C-y>` to accept.

### Formatting & Code Quality

Formatting occurs automatically on file save (`:w`). Neovim delegates this to `gopls`, which uses `gofumpt` (configured in `flake.nix` and `gopls` settings) to strictly format imports and structural alignment.

### Diagnostics

Compiler warnings, unused variables, and shadow declarations highlight automatically in the sign column. Press `<leader>e` to inspect the error under the cursor or `<leader>q` to view all diagnostics in a quickfix window.

### Compile, Run & Test

- **Compile Check**: Press `<leader>gb`. If errors occur, open the quickfix window (`:copen`) to jump directly to breaking line numbers.
- **Run Application**: Press `<leader>gr` to open a terminal split and execute `go run .`. Press `i` to interact with the process.
- **Run Unit Tests**: Press `<leader>gt` to run all project tests verbosely.

---

## 🔎 Version & Correctness Notes

The configuration above is unmodified. These are the places where it depends on a specific Neovim version or where behaviour differs from what the surrounding prose implies — worth knowing before you debug something that is working as written.

### `vim.fs.root` needs Neovim 0.10+

`vim.fs.root()` was added in 0.10, so the LSP block will error on the 0.8 baseline given under [Prerequisites](#prerequisites). If you need to support 0.8/0.9, substitute:

```lua
root_dir = vim.fs.dirname(vim.fs.find({ "go.work", "go.mod", ".git" }, {
  path = vim.api.nvim_buf_get_name(args.buf),
  upward = true,
})[1]),
```

### `expandtab = true` versus `gofmt`

Go is formatted with tabs, not spaces. Because format-on-save routes through `gopls`/`gofumpt`, indentation is rewritten to tabs every time you write the file — so this setting only affects what you type before the first save, and the two will visibly disagree in that window. Setting `vim.opt.expandtab = false` for Go buffers avoids the churn. It is harmless either way; the file on disk is always correct.

### `vim.diagnostic.goto_prev` / `goto_next` are deprecated

Deprecated in 0.11 in favour of `vim.diagnostic.jump()`. They still function, but emit a deprecation warning. The forward-compatible form:

```lua
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
```

### `<C-Space>` may not reach Neovim

Many terminals transmit `Ctrl-Space` as `<Nul>`. If the mapping appears dead, add the alias:

```lua
vim.keymap.set("i", "<C-@>", "<C-x><C-o>", opts)
```

`<C-x><C-o>` always works and needs no mapping at all.

### `GOPATH="$HOME/go"` is shared, not per-project

The Overview describes dependencies as "isolated per-project". That holds for the tools themselves — `go`, `gopls`, `gofumpt`, `golangci-lint`, `delve` all come from the flake — but the `shellHook` points `GOPATH` at the global default, so the module and build caches are shared across every project. That is usually what you want (cache reuse). For genuine per-project isolation, use `export GOPATH="$PWD/.direnv/go"` and add `.direnv/` to `.gitignore`.

Also worth adding, since a `go` directive in `go.mod` newer than the flake's Go will make the `go` command silently download and run a different toolchain:

```bash
export GOTOOLCHAIN=local   # fail loudly instead of substituting a toolchain
```

### `golangci-lint` and `delve` have no keybindings

Both are installed by the flake but unbound in `init.lua`, so they are used from the shell:

```bash
golangci-lint run          # lint; --fix applies the autofixable subset
dlv debug .                # debug the current package
dlv test ./internal/config # debug a package's tests
```

Neovim has no built-in DAP client, so `delve` runs as its own TUI — `:split | terminal dlv debug .` keeps it inside the editor. To route the linter through the quickfix list instead:

```lua
vim.bo.makeprg = "golangci-lint run"
vim.bo.errorformat = "%f:%l:%c: %m,%f:%l: %m"
```

### `flake.lock`

Commit it. Without the lockfile, `nixos-unstable` drifts and the environment stops being reproducible — which is the reason for using a flake in the first place. Update deliberately with `nix flake update && direnv reload`.

# dotfiles

## OpenCode custom commands

The custom OpenCode slash commands are stored in [`opencode/commands`](opencode/commands):

- [`implement-issue`](opencode/commands/implement-issue.md): update `main`, implement an open GitHub issue, and submit a pull request.
- [`finish-pr`](opencode/commands/finish-pr.md): verify a pull request is merged, return to `main`, and check that the working tree is clean and up to date.
- [`add-screenshots`](opencode/commands/add-screenshots.md): upload screenshots through the GitHub attachments API using `gh` and embed them in an MR (GitHub pull request) description.
- [`audit-k8s-resources`](opencode/commands/audit-k8s-resources.md): inspect non-system Kubernetes workloads using `kubectl`, adjust locally cloned applications from fresh `main` using real CPU/memory metrics, submit MRs, and finish with a summary table.

These are command definitions, rather than `SKILL.md` skills. Their original global location is `~/.config/opencode/commands/`.

### Install commands individually using OpenCode

On another machine, paste the prompt for the command you want into OpenCode. Each prompt installs just that command; cloning this repository is not required.

**Install `/implement-issue`:**

```text
Install the OpenCode v2 custom slash command implement-issue globally. Fetch https://raw.githubusercontent.com/mucsi96/dotfiles/master/opencode/commands/implement-issue.md and save its exact Markdown contents, including frontmatter, to ~/.config/opencode/commands/implement-issue.md. Create the commands directory if needed. Read back the saved file to verify it matches the source. Tell me to type /implement-issue in the TUI to find the command, but do not execute it during installation. OpenCode v2 reloads command files automatically.
```

**Install `/finish-pr`:**

```text
Install the OpenCode v2 custom slash command finish-pr globally. Fetch https://raw.githubusercontent.com/mucsi96/dotfiles/master/opencode/commands/finish-pr.md and save its exact Markdown contents, including frontmatter and the literal $ARGUMENTS placeholder, to ~/.config/opencode/commands/finish-pr.md. Create the commands directory if needed. Read back the saved file to verify it matches the source. Tell me to type /finish-pr in the TUI to find the command and that it accepts a PR number or URL, but do not execute it during installation. OpenCode v2 reloads command files automatically.
```

**Install `/add-screenshots`:**

```text
Install the OpenCode v2 custom slash command add-screenshots globally. Fetch https://raw.githubusercontent.com/mucsi96/dotfiles/master/opencode/commands/add-screenshots.md and save its exact Markdown contents, including frontmatter and the literal $ARGUMENTS placeholder, to ~/.config/opencode/commands/add-screenshots.md. Create the commands directory if needed. Read back the saved file to verify it matches the source. Tell me to type /add-screenshots in the TUI to find the command and that it accepts a PR number or URL and screenshot paths, but do not execute it during installation. OpenCode v2 reloads command files automatically.
```

Example: `/add-screenshots 123 "screenshots/before.png" "screenshots/after.png"`. Omit the PR number to use the current conversation or branch. The command preserves the existing PR description and adds uploaded images to its Screenshots section.

**Install `/audit-k8s-resources`:**

```text
Install the OpenCode v2 custom slash command audit-k8s-resources globally. Fetch https://raw.githubusercontent.com/mucsi96/dotfiles/master/opencode/commands/audit-k8s-resources.md and save its exact Markdown contents, including frontmatter and the literal $ARGUMENTS placeholder, to ~/.config/opencode/commands/audit-k8s-resources.md. Create the commands directory if needed. Read back the saved file to verify it matches the source. Tell me to type /audit-k8s-resources in the TUI to find the command, but do not execute it during installation. OpenCode v2 reloads command files automatically.
```

Run `/audit-k8s-resources` for the current cluster's non-system workloads, or `/audit-k8s-resources context production, namespaces apps and data, last 14 days` to specify scope. It requires configured `kubectl` access, Git, and an authenticated host CLI (`gh` for GitHub or `glab` for GitLab). Metrics Server supplies live usage; existing historical monitoring improves decisions. The command identifies locally cloned source repositories, immediately implements evidence-backed changes in separate worktrees branched from freshly fetched `origin/main`, validates them, and submits one MR per repository targeting `main`. It preserves existing local work and reports missing metrics, uncertain repository matches, and other blockers. It ends with a table of resource changes, validation results, and MR links. MRs are not automatically merged, and cluster resources are not directly modified.

For a project-local installation, run OpenCode in that project and replace the destination in the prompt with `.opencode/commands/<command-name>.md`.

### OpenCode v2 compatibility

These files follow the [official OpenCode v2 command format](https://opencode.ai/v2/docs/commands/): `.md` files in `commands/`, optional YAML `description` frontmatter, and a Markdown body used as the prompt. The `$ARGUMENTS` placeholders in command files are supported by v2 and must be preserved literally during installation.

OpenCode v2 reloads command files automatically; no restart is required. Type `/implement-issue`, `/finish-pr`, `/add-screenshots`, or `/audit-k8s-resources` in the TUI to check discovery, then submit when ready to run the workflow. For example, `/finish-pr 123` passes `123` to the prompt. Project-local commands with the same name override global commands. On older OpenCode versions, quit and restart after installing if needed.

The GitHub commands require Git and an authenticated GitHub CLI (`gh auth login`). `implement-issue` and `finish-pr` assume the target repository uses `main` as its default branch. `add-screenshots` requires image files and repository write access; GitHub Enterprise Server does not support the attachments upload endpoint. It uses `gh api` directly, so it does not require the newer `--attach` flag.

## Install Java

1. Sign in to Oracle site
2. Download the `.deb` binary
3. Double click to install it
4. Run the following commands

```
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-11*/bin/java 1081 
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-11*/bin/javac 1081 
sudo update-alternatives --install /usr/bin/javadoc javadoc /usr/lib/jvm/jdk-11*/bin/javadoc 1081 
sudo update-alternatives --install /usr/bin/javap javap /usr/lib/jvm/jdk-11*/bin/javap 1081
```

5. Check the setup

```
java -version
```

## Install IDEA

1. Download the `.tar.gz` binary
2. Run the following commands

```
sudo mkdir -p /usr/lib/idea
sudo tar -xvf ./ideaIC-2019.3.3.tar.gz -C /usr/lib/idea
/usr/lib/idea/idea-IC-193.6494.35/bin/idea.sh
```

## Install NodeJs

1. Download the `tar.xz` binary
2. Run the following commands

```
sudo mkdir -p /usr/lib/nodejs
sudo tar -xJvf node-v12.16.1-linux-x64.tar.xz -C /usr/lib/nodejs
sudo mv /usr/lib/nodejs/node-v12.16.1-linux-x64/ /usr/lib/nodejs/node-v12.16.1
sudo update-alternatives --install /usr/bin/node node /usr/lib/nodejs/node-v12.16.1/bin/node 1081
sudo update-alternatives --install /usr/bin/npm npm /usr/lib/nodejs/node-v12.16.1/bin/npm 1081
sudo update-alternatives --install /usr/bin/npx npx /usr/lib/nodejs/node-v12.16.1/bin/npx 1081
```

3. Check the setup

```
node --version
npm --version
npx --version
```

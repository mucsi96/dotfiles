# dotfiles

## OpenCode custom commands

The custom OpenCode slash commands are stored in [`opencode/commands`](opencode/commands):

- [`implement-issue`](opencode/commands/implement-issue.md): update `main`, implement an open GitHub issue, and submit a pull request.
- [`finish-pr`](opencode/commands/finish-pr.md): verify a pull request is merged, return to `main`, and check that the working tree is clean and up to date.

These are command definitions, rather than `SKILL.md` skills. Their original global location is `~/.config/opencode/commands/`.

To install them on another machine, run from the root of this repository:

```sh
mkdir -p ~/.config/opencode/commands
cp opencode/commands/*.md ~/.config/opencode/commands/
```

For a project-local installation, copy the files into that project's `.opencode/commands/` directory instead.

Quit and restart OpenCode after installing, then use `/implement-issue` or `/finish-pr [PR number or URL]`. Both commands require Git and an authenticated GitHub CLI (`gh auth login`), and assume the target repository uses `main` as its default branch.

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

# Python

https://realpython.com/intro-to-pyenv/

## Install PyEnv

https://github.com/pyenv/pyenv?tab=readme-ov-file#unixmacos

```bash
brew update
brew upgrade
brew install pyenv
brew install pyenv-virtualenv
```

```bash
ehco '####################### PYENV #######################'
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
echo '#####################################################'
```

### List available versions

```bash
pyenv install --list | grep " 3\.12"
```

### List installed versions

```bash
pyenv versions
```

### Install python

```bash
pyenv install 3.12.3
```

### Create local virtual environment

```bash
pyenv virtualenv 3.12.3 cloud-roles
pyenv local cloud-roles
```

### Remove virtual environment

```bash
pyenv virtualenv-delete cloud-roles
```

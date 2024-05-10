# Python

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

cd /d %~dp0
del "%USERPROFILE%\.gitconfig"
mklink "%USERPROFILE%\.gitconfig" "%cd%\.gitconfig"

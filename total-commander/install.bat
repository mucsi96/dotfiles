cd /d %~dp0

del "c:\totalcmd\open-boot2docker.bat"
del "c:\totalcmd\diff.bat"
del "c:\totalcmd\open-vagrant-docker.js"
del "%USERPROFILE%\AppData\Roaming\GHISLER\usercmd.ini"

mklink "c:\totalcmd\open-boot2docker.bat" "%cd%\open-boot2docker.bat"
mklink "c:\totalcmd\diff.bat" "%cd%\diff.bat"
mklink "c:\totalcmd\open-vagrant-docker.js" "%cd%\open-vagrant-docker.js"
mklink "%USERPROFILE%\AppData\Roaming\GHISLER\usercmd.ini" "%cd%\usercmd.ini"

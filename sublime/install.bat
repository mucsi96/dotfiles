cd /d %~dp0
rd /S "%USERPROFILE%\AppData\Roaming\Sublime Text 3\Packages\User"
mklink /D "%USERPROFILE%\AppData\Roaming\Sublime Text 3\Packages\User" "%cd%\User"
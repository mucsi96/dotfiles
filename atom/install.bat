cd /d %~dp0
rd /S "%USERPROFILE%\.atom"
mklink /D "%USERPROFILE%\.atom" "%cd%\.atom"

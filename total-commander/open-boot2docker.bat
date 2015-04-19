@echo off
setlocal ENABLEDELAYEDEXPANSION
set lpath=/%1
set lpath=%lpath:\=/%
set lpath=%lpath::=%

for /f %%i in ('boot2docker status') do set result=%%i
If NOT "%result%"=="%result:running=%" (
    echo boot2docker is running
) else (
    echo boot2docker need to be started
    boot2docker up
)

start "" "C:\Program Files (x86)\PuTTY\kitty.exe" -load "boot2docker" -cmd "cd %lpath% ; ./up.sh"

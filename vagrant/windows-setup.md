1. Open an administrative cmd
2. Install Chocolatey: @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
3. Run: cinst vagrant virtualbox cyg-get
4. Open an administrative cmd
5. Run: cyg-get openssh, rsync, ncurses

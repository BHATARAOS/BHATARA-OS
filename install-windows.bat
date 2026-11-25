@echo off
chcp 65001 >nul
title BHATARA OS v2.0.1.2 - Windows Installer (WSL2)
where wsl >nul 2>&1 || (echo [E] Jalankan di PowerShell Admin: wsl --install -d Ubuntu-22.04 & pause & exit /b 1)
wsl -l -q 2>nul | findstr /I "Ubuntu" >nul || (wsl --install -d Ubuntu-22.04 & pause & exit /b 0)
set "WIN_DIR=%~dp0"
if "%WIN_DIR:~-1%"=="\" set "WIN_DIR=%WIN_DIR:~0,-1%"
wsl bash -c "cd \"$(wslpath '%WIN_DIR%')\" && sed -i 's/\r$//' install.sh scripts/*.sh 2>/dev/null || true && chmod +x install.sh scripts/*.sh && bash install.sh"
pause

@echo off
chcp 65001 >nul
title BHATARA OS v2.0.1.2 - Windows Launcher
echo 1) XFCE4  2) MATE  3) GNOME Flashback  4) Stop Server
set /p CHOICE="Pilihan [1-4] (default 1): "
if "%CHOICE%"=="" set "CHOICE=1"
if "%CHOICE%"=="4" (wsl bash -c "bhatara stop" & pause & exit /b 0)
set "VAR=xfce4"
if "%CHOICE%"=="2" set "VAR=mate"
if "%CHOICE%"=="3" set "VAR=gnome"
wsl bash -c "bhatara %VAR% 1366x768"
echo Hubungkan TigerVNC / RealVNC Viewer ke: 127.0.0.1:5901
pause

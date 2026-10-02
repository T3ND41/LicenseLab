@echo off
setlocal
title LicenseLab v3.1

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SCRIPT=%~dp0LicenseServiceToolkit.ps1"
if not exist "%SCRIPT%" (
    echo.
    echo [ERROR] LicenseServiceToolkit.ps1 was not found.
    echo Keep this BAT file and the PS1 file in the same folder.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%errorlevel%"

echo.
if not "%RC%"=="0" echo Toolkit exited with code %RC%.
pause
exit /b %RC%

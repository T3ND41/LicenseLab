@echo off
setlocal
title LicenseLab v3.1.2

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -Verb RunAs -ArgumentList '/k ""%~f0""'"
    exit /b
)

set "SCRIPT=%~dp0LicenseLab-v3.1.2.ps1"
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
if not "%RC%"=="0" (
    echo.
    echo [ERROR] LicenseLab exited with code %RC%.
    echo The window will remain open so you can copy the error.
)
echo.
echo Type EXIT to close this window when finished.
cmd /k


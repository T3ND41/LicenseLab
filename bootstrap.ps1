$ErrorActionPreference = 'Stop'
$RepoRaw = 'https://raw.githubusercontent.com/T3ND41/LicenseLab/main'
$InstallDir = Join-Path $env:LOCALAPPDATA 'LicenseLab'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    $self = Join-Path $env:TEMP 'LicenseLab-bootstrap.ps1'
    Invoke-WebRequest -UseBasicParsing "$RepoRaw/bootstrap.ps1" -OutFile $self
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$self`""
    return
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "              LicenseLab                    " -ForegroundColor Cyan
Write-Host "      Install / Update / Launch             " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$folders = @(
    'Tools\ODT',
    'GeneratedConfigs',
    'Logs',
    'ServiceHistory'
)
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path (Join-Path $InstallDir $folder) -Force | Out-Null
}

$files = @(
    'LicenseServiceToolkit.ps1',
    'Run-LicenseServiceToolkit.bat',
    'README.md',
    'NOTICE.txt',
    'Tools/ODT/README.txt'
)

foreach ($file in $files) {
    $url = "$RepoRaw/$file"
    $dest = Join-Path $InstallDir ($file -replace '/', '\')
    New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
    Write-Host "Downloading $file..."
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $dest
}

$updateCmd = Join-Path $InstallDir 'Update-LicenseLab.cmd'
'@echo off' | Set-Content $updateCmd -Encoding ASCII
'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1 | iex"' | Add-Content $updateCmd -Encoding ASCII

try {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shortcutPath = Join-Path $desktop 'LicenseLab.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = Join-Path $InstallDir 'Run-LicenseServiceToolkit.bat'
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Description = 'LicenseLab Windows and Office service toolkit'
    $shortcut.Save()
} catch {}

Write-Host ""
Write-Host "[+] LicenseLab installed/updated:" -ForegroundColor Green
Write-Host "    $InstallDir"
Write-Host "[+] Launching..." -ForegroundColor Green

Start-Process -FilePath (Join-Path $InstallDir 'Run-LicenseServiceToolkit.bat')

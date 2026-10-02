$ErrorActionPreference = 'Stop'
$RepoRaw = 'https://raw.githubusercontent.com/T3ND41/LicenseLab/main'
$InstallDir = Join-Path $env:LOCALAPPDATA 'LicenseLab'
$CacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$NoCacheHeaders = @{ 'Cache-Control'='no-cache, no-store, max-age=0'; 'Pragma'='no-cache' }

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    $self = Join-Path $env:TEMP 'LicenseLab-bootstrap.ps1'
    Invoke-WebRequest -UseBasicParsing -Headers $NoCacheHeaders -Uri "$RepoRaw/bootstrap.ps1?v=$CacheBust" -OutFile $self
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
    'LicenseLab-v3.1.2.ps1',
    'Run-LicenseServiceToolkit.bat',
    'README.md',
    'NOTICE.txt',
    'Tools/ODT/README.txt'
)

foreach ($file in $files) {
    $url = "$RepoRaw/$file?v=$CacheBust"
    $dest = Join-Path $InstallDir ($file -replace '/', '\')
    $tmp  = "$dest.download"
    New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
    Write-Host "Downloading fresh copy of $file..."
    if (Test-Path $tmp)  { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    Invoke-WebRequest -UseBasicParsing -Headers $NoCacheHeaders -Uri $url -OutFile $tmp
    Move-Item -Path $tmp -Destination $dest -Force
}

$updateCmd = Join-Path $InstallDir 'Update-LicenseLab.cmd'
'@echo off' | Set-Content $updateCmd -Encoding ASCII
'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$u=''https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1?v=''+[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds(); iex (irm $u -Headers @{''Cache-Control''=''no-cache''})"' | Add-Content $updateCmd -Encoding ASCII

try {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shortcutPath = Join-Path $desktop 'LicenseLab.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$env:SystemRoot\System32\cmd.exe"
    $shortcut.Arguments = '/k ""' + (Join-Path $InstallDir 'Run-LicenseServiceToolkit.bat') + '""'
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Description = 'LicenseLab Windows and Office service toolkit'
    $shortcut.Save()
} catch {}

Write-Host ""
Write-Host "[+] LicenseLab installed/updated:" -ForegroundColor Green
Write-Host "    $InstallDir"
# Verify that the newly downloaded toolkit is the patched build before launch.
$mainScript = Join-Path $InstallDir 'LicenseLab-v3.1.2.ps1'
if (-not (Select-String -Path $mainScript -SimpleMatch 'LicenseLab v3.1.2' -Quiet)) {
    throw "Fresh LicenseLab v3.1.2 was not downloaded. Delete $InstallDir and run the bootstrap again."
}

Write-Host "[+] Verified patched build: LicenseLab v3.1.2" -ForegroundColor Green
Write-Host "[+] Launching..." -ForegroundColor Green

$launcher = Join-Path $InstallDir 'Run-LicenseServiceToolkit.bat'
Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList @('/k',('"' + $launcher + '"')) -WorkingDirectory $InstallDir

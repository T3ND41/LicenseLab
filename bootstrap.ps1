$ErrorActionPreference = 'Stop'

$uri = 'https://raw.githubusercontent.com/T3ND41/LicenseLab/main/LicenseLab.ps1?v=' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

try {
    $code = Invoke-RestMethod -UseBasicParsing -Uri $uri -Headers @{ 'Cache-Control'='no-cache, no-store, max-age=0'; 'Pragma'='no-cache' }

    if (-not $code -or $code.Length -lt 100) {
        throw 'The downloaded LicenseLab script was empty or incomplete.'
    }

    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseInput($code,[ref]$tokens,[ref]$parseErrors) | Out-Null

    if ($parseErrors.Count -gt 0) {
        Write-Host ''
        Write-Host 'LicenseLab was downloaded, but PowerShell found syntax errors before execution:' -ForegroundColor Red
        foreach ($err in $parseErrors) {
            Write-Host ('Line {0}, Column {1}: {2}' -f $err.Extent.StartLineNumber,$err.Extent.StartColumnNumber,$err.Message) -ForegroundColor Red
        }
        Write-Host ''
        [void](Read-Host 'Press Enter to return')
        return
    }

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host ''
        Write-Host 'LicenseLab must be run from an Administrator PowerShell or Windows Terminal.' -ForegroundColor Yellow
        Write-Host 'This rebuilt launcher will not open or close another console window.' -ForegroundColor Yellow
        Write-Host ''
        Write-Host 'Right-click PowerShell or Windows Terminal > Run as administrator, then run:' -ForegroundColor Cyan
        Write-Host 'irm https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1 | iex' -ForegroundColor Cyan
        Write-Host ''
        [void](Read-Host 'Press Enter to return')
        return
    }

    & ([scriptblock]::Create($code))
}
catch {
    Write-Host ''
    Write-Host 'LicenseLab launcher error:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    [void](Read-Host 'Press Enter to return')
}

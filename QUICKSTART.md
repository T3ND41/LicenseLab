# LicenseLab v3.1

## One-line install, update, and launch

When the repository is public, run:

```powershell
irm https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1 | iex
```

Run the same command again later to update LicenseLab.

LicenseLab installs under:

`%LOCALAPPDATA%\LicenseLab`

It also creates an updater command, persistent logs/history/config folders, and a desktop shortcut when permitted.

## Office Deployment Tool

Place Microsoft's official ODT `setup.exe` at:

`%LOCALAPPDATA%\LicenseLab\Tools\ODT\setup.exe`

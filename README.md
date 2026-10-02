# LicenseLab v3.1

## One-line install, update, and launch

After the GitHub repository is public and these files are pushed, run:

```powershell
irm https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1 | iex
```

The same command can be used later to update LicenseLab.

It installs the toolkit into:

`%LOCALAPPDATA%\LicenseLab`

It also creates:
- a desktop shortcut when permitted
- `Update-LicenseLab.cmd`
- persistent Logs
- persistent ServiceHistory
- persistent GeneratedConfigs
- the `Tools\ODT` folder

## Office Deployment Tool

Place Microsoft's official ODT `setup.exe` at:

`%LOCALAPPDATA%\LicenseLab\Tools\ODT\setup.exe`

## Main toolkit

LicenseLab organizes the technician workflow into six sections:

1. Windows
2. Office
3. Install / Modify
4. License & Timer
5. Repair
6. Technician

### Windows
- activation status
- install an authorized product key and request normal activation
- supported Windows edition discovery
- change/upgrade Windows edition with a valid target-edition key
- remove installed Windows product key

### Office
- installation/version/channel/license status
- install an authorized Office product key and request normal activation
- remove an Office product key
- Office deployment and app/version management

### Install / Modify
- install or switch Office product/version
- add/remove Office apps
- choose Word, Excel, PowerPoint, Outlook, Access, OneNote, Publisher, Teams, OneDrive
- 32-bit <-> 64-bit migration
- update-channel changes
- source download for offline/later deployment
- Click-to-Run Office removal
- Microsoft Office Customization Tool

### License & Timer
Choose Windows, Office, or both, then select:
- 30 minutes
- 2 hours
- 1 day
- 3 days
- 7 days
- custom minutes
- custom hours
- custom days

At expiry, LicenseLab performs the configured legitimate key-removal/deactivation action using Windows Task Scheduler.

### Repair
- licensing-service checks
- time/date synchronization
- DISM ScanHealth
- DISM RestoreHealth
- SFC
- Windows Activation settings
- Office repair

### Technician
- system information
- customer diagnostic reports
- service history
- logs
- generated Office deployment configs

## Licensing scope

LicenseLab supports legitimate Windows and Office servicing, deployment, authorized key management, scheduled deactivation, diagnostics, repair, and reporting.

It does not contain activation cracks, embedded Microsoft product keys, HWID bypasses, Ohook, TSforge, or unauthorized KMS activation services.

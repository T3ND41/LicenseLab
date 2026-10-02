# LicenseLab v4

LicenseLab is a compact Windows and Microsoft Office technician toolkit.

## Recommended launch

Open **PowerShell or Windows Terminal as Administrator**, then run:

```powershell
irm https://raw.githubusercontent.com/T3ND41/LicenseLab/main/bootstrap.ps1 | iex
```

LicenseLab v4 runs entirely in the PowerShell window you opened.

It does **not**:
- install itself under AppData before launch
- open a BAT file
- open a second CMD window
- self-elevate into another console
- close your current PowerShell window

The bootstrap downloads `LicenseLab.ps1`, checks it with PowerShell's parser, and only executes it when no parse errors are found.

## Main sections

1. **Windows**
   - activation status
   - install an authorized product key and request normal activation
   - edition discovery/change
   - remove the installed key

2. **Office**
   - installation and licensing status
   - install an authorized Office key
   - request normal activation
   - remove an installed Office key

3. **Install / Modify**
   - Office Deployment Tool workflows
   - product/version selection
   - app selection
   - 32/64-bit migration
   - update channels
   - offline source download
   - Click-to-Run removal

4. **License & Timer**
   - Windows, Office, or both
   - 30 minutes, 2 hours, 1 day, 3 days, 7 days
   - custom minutes/hours/days
   - scheduled legitimate key removal/deactivation
   - view/cancel timer jobs

5. **Repair**
   - licensing services
   - time sync
   - DISM
   - SFC
   - Windows Activation settings
   - Office repair shortcut

6. **Technician**
   - system information
   - diagnostic reports
   - service history
   - logs

## Office Deployment Tool

When using Install / Modify, LicenseLab looks for Microsoft ODT `setup.exe` and can open Microsoft's official ODT download page if it is not available.

Generated ODT XML files are stored under:

`C:\ProgramData\LicenseLab\Configs`

## Service timers

Timers use Windows Task Scheduler.

They control when LicenseLab removes the installed product key/configuration. They do not alter Microsoft's entitlement lifetime.

A PC with a Windows digital entitlement may automatically reactivate after product-key removal.

## Licensing scope

LicenseLab is for legitimate servicing using licenses, subscriptions, product keys, digital entitlements, and organizational activation infrastructure you are authorized to manage.

It does not contain activation cracks, HWID bypasses, Ohook, TSforge, or unauthorized/public KMS activation.

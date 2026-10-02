#requires -version 5.1
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $MyInvocation.MyCommand.Path
$Logs=Join-Path $Root 'Logs';$Cfg=Join-Path $Root 'GeneratedConfigs';$Hist=Join-Path $Root 'ServiceHistory';$Odt=Join-Path $Root 'Tools\ODT\setup.exe'
@($Logs,$Cfg,$Hist,(Split-Path $Odt -Parent))|%{New-Item -ItemType Directory -Force -Path $_|Out-Null}
function P{Write-Host '';[void](Read-Host 'Press Enter to continue')}
function H($s=''){Clear-Host;Write-Host '========================================' -ForegroundColor Cyan;Write-Host '              LicenseLab v3.1.1          ' -ForegroundColor Cyan;Write-Host '========================================' -ForegroundColor Cyan;if($s){Write-Host "`n$s" -ForegroundColor Yellow};Write-Host ''}
function Admin{$i=[Security.Principal.WindowsIdentity]::GetCurrent();$p=New-Object Security.Principal.WindowsPrincipal($i);$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function Log($a,$r='OK'){$f=Join-Path $Hist ("history-{0}.csv"-f(Get-Date -Format yyyy-MM));if(!(Test-Path $f)){'"Time","PC","Action","Result"'|Set-Content $f};('"{0}","{1}","{2}","{3}"'-f(Get-Date -Format s),$env:COMPUTERNAME,$a.Replace('"','""'),$r.Replace('"','""'))|Add-Content $f}
function OSPP{$c=@("$env:ProgramFiles\Microsoft Office\Office16\OSPP.VBS","$env:ProgramFiles\Microsoft Office\root\Office16\OSPP.VBS","${env:ProgramFiles(x86)}\Microsoft Office\Office16\OSPP.VBS","${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\OSPP.VBS");foreach($x in $c){if($x -and(Test-Path $x)){return $x}}$null}
function C2R{foreach($p in @('HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration')){if(Test-Path $p){try{return Get-ItemProperty $p}catch{}}}}
function ReadKey($label){$k=(Read-Host $label).Trim();if($k -match '^[A-Za-z0-9]{5}(-[A-Za-z0-9]{5}){4}$'){return $k};Write-Host 'Invalid key format.' -ForegroundColor Red;$null}
function WinStatus{H 'WINDOWS > Status';cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr;cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dlv;Log 'Windows status';P}
function WinActivate{H 'WINDOWS > Activate';$k=ReadKey 'Enter authorized Windows key';if(!$k){P;return};cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $k;cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato;Log 'Windows activation requested';P}
function WinRemove{H 'WINDOWS > Remove key';if((Read-Host 'Type REMOVE to continue')-cne'REMOVE'){return};cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /upk;cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /cpky;Log 'Windows key removed';P}
function WinEdition{H 'WINDOWS > Edition';DISM.exe /Online /Get-CurrentEdition;DISM.exe /Online /Get-TargetEditions;if((Read-Host 'Change edition with valid key? Y/N')-match'^(?i)y'){ $k=ReadKey 'Target-edition key';if($k){Start-Process "$env:SystemRoot\System32\changepk.exe" -ArgumentList "/ProductKey $k" -Wait;Log 'Windows edition change'}};P}
function OfficeStatus{H 'OFFICE > Status';$c=C2R;if($c){[pscustomobject]@{Products=$c.ProductReleaseIds;Platform=$c.Platform;Version=$c.ClientVersionToReport;Channel=$c.UpdateChannel}|fl};$o=OSPP;if($o){cscript.exe //nologo $o /dstatus}else{Write-Host 'OSPP.VBS not found.' -ForegroundColor Yellow};Log 'Office status';P}
function OfficeActivate{H 'OFFICE > Activate';$o=OSPP;if(!$o){Write-Host 'OSPP.VBS not found.';P;return};$k=ReadKey 'Enter authorized Office key';if($k){cscript.exe //nologo $o /inpkey:$k;cscript.exe //nologo $o /act;Log 'Office activation requested'};P}
function OfficeKeyId{param([string]$o);$out=cscript.exe //nologo $o /dstatus 2>&1;foreach($l in $out){if($l-match'Last 5 characters of installed product key:\s*([A-Z0-9]{5})'){return $matches[1]}}$m=(Read-Host 'Last 5 chars of Office key, or Enter to cancel').Trim().ToUpper();if($m-match'^[A-Z0-9]{5}$'){return $m};$null}
function OfficeRemove{H 'OFFICE > Remove key';$o=OSPP;if(!$o){Write-Host 'OSPP.VBS not found.';P;return};$id=OfficeKeyId $o;if($id){cscript.exe //nologo $o /unpkey:$id;Log 'Office key removed'};P}
function NeedODT{if(Test-Path $Odt){return $true};Write-Host "ODT setup.exe missing at $Odt" -ForegroundColor Yellow;if((Read-Host 'Open Microsoft ODT download page? Y/N')-match'^(?i)y'){Start-Process 'https://www.microsoft.com/en-us/download/details.aspx?id=49117'};P;$false}
function Apps{$all=@('Access','Excel','OneDrive','OneNote','Outlook','PowerPoint','Publisher','Teams','Word');Write-Host '[1] Full [2] Basic [3] Standard [4] Business [5] Custom';switch(Read-Host 'Preset'){'2'{@('Word','Excel','PowerPoint')}'3'{@('Word','Excel','PowerPoint','Outlook','OneNote')}'4'{@('Word','Excel','PowerPoint','Outlook','OneNote','Teams','OneDrive')}'5'{$s=@();foreach($a in $all){if((Read-Host "Keep $a? Y/N")-match'^(?i)y'){$s+=$a}};$s}default{$all}}}
function Product{Write-Host '[1] M365 Enterprise [2] M365 Business [3] LTSC ProPlus 2024 [4] LTSC Standard 2024 [5] LTSC ProPlus 2021';switch(Read-Host 'Product'){'2'{'O365BusinessRetail'}'3'{'ProPlus2024Volume'}'4'{'Standard2024Volume'}'5'{'ProPlus2021Volume'}default{'O365ProPlusRetail'}}}
function Channel{Write-Host '[1] Current [2] MonthlyEnterprise [3] SemiAnnual [4] PerpetualVL2024 [5] PerpetualVL2021';switch(Read-Host 'Channel'){'2'{'MonthlyEnterprise'}'3'{'SemiAnnual'}'4'{'PerpetualVL2024'}'5'{'PerpetualVL2021'}default{'Current'}}}
function MakeCfg($prod,$arch,$chan,$apps,$migrate=$false){
    $all=@('Access','Excel','OneDrive','OneNote','Outlook','PowerPoint','Publisher','Teams','Word')
    $p=Join-Path $Cfg ("office-{0}.xml" -f (Get-Date -Format yyyyMMddHHmmss))
    $mig=if($migrate){' MigrateArch="TRUE"'}else{''}

    $x=@()
    $x+='<Configuration>'
    $x+=('  <Add OfficeClientEdition="{0}" Channel="{1}"{2}>' -f $arch,$chan,$mig)
    $x+=('    <Product ID="{0}">' -f $prod)
    $x+='      <Language ID="MatchInstalled" TargetProduct="All" />'
    foreach($a in ($all | Where-Object { $apps -notcontains $_ })){
        $x+=('      <ExcludeApp ID="{0}" />' -f $a)
    }
    $x+='    </Product>'
    $x+='  </Add>'
    $x+='  <Updates Enabled="TRUE" />'
    $x+='  <Display Level="Full" AcceptEULA="TRUE" />'
    $x+='</Configuration>'
    $x | Set-Content $p -Encoding UTF8
    return $p
}
function InstallModify{
    H 'INSTALL / MODIFY'
    if(!(NeedODT)){return}

    Write-Host '[1] Install/switch product'
    Write-Host '[2] Add/remove apps'
    Write-Host '[3] Migrate 32/64'
    Write-Host '[4] Change channel'
    Write-Host '[5] Remove C2R Office'
    Write-Host '[0] Back'

    switch(Read-Host 'Select'){
        '1'{
            $p=Product
            $a=if((Read-Host 'Arch [1]64 [2]32') -eq '2'){'32'}else{'64'}
            $ch=Channel
            $cfg=MakeCfg $p $a $ch @(Apps)
            Start-Process $Odt -ArgumentList @('/configure',$cfg) -Wait
            Log 'Office install/switch'
        }
        '2'{
            $c=C2R
            if(!$c){Write-Host 'C2R Office not detected.';P;return}
            $p=($c.ProductReleaseIds -split ',')[0]
            $a=if($c.Platform -match 'x86'){'32'}else{'64'}
            $cfg=MakeCfg $p $a 'Current' @(Apps)
            Start-Process $Odt -ArgumentList @('/configure',$cfg) -Wait
            Log 'Office apps modified'
        }
        '3'{
            $c=C2R
            if(!$c){Write-Host 'C2R Office not detected.';P;return}
            $p=($c.ProductReleaseIds -split ',')[0]
            $a=if((Read-Host 'Target arch [1]64 [2]32') -eq '2'){'32'}else{'64'}
            $cfg=MakeCfg $p $a (Channel) @(Apps) $true
            Start-Process $Odt -ArgumentList @('/configure',$cfg) -Wait
            Log 'Office architecture migration'
        }
        '4'{
            $ch=Channel
            $cfg=Join-Path $Cfg 'channel.xml'
            @(
                '<Configuration>',
                ('  <Updates Enabled="TRUE" Channel="{0}" />' -f $ch),
                '</Configuration>'
            ) | Set-Content $cfg -Encoding UTF8
            Start-Process $Odt -ArgumentList @('/configure',$cfg) -Wait
            Log 'Office channel change'
        }
        '5'{
            if((Read-Host 'Type REMOVE-OFFICE') -ceq 'REMOVE-OFFICE'){
                $cfg=Join-Path $Cfg 'remove.xml'
                @(
                    '<Configuration>',
                    '  <Remove All="TRUE" />',
                    '  <Display Level="Full" AcceptEULA="TRUE" />',
                    '</Configuration>'
                ) | Set-Content $cfg -Encoding UTF8
                Start-Process $Odt -ArgumentList @('/configure',$cfg) -Wait
                Log 'Office removed'
            }
        }
        '0'{return}
    }
    P
}
function Duration{Write-Host '[1]30m [2]2h [3]1d [4]3d [5]7d [6]custom minutes [7]custom hours [8]custom days';switch(Read-Host 'Duration'){'1'{(Get-Date).AddMinutes(30)}'2'{(Get-Date).AddHours(2)}'3'{(Get-Date).AddDays(1)}'4'{(Get-Date).AddDays(3)}'5'{(Get-Date).AddDays(7)}'6'{(Get-Date).AddMinutes([double](Read-Host 'Minutes'))}'7'{(Get-Date).AddHours([double](Read-Host 'Hours'))}'8'{(Get-Date).AddDays([double](Read-Host 'Days'))}default{$null}}}
function Timer{
    H 'LICENSE & TIMER'
    Write-Host '[1] Windows [2] Office [3] Both'
    $s=Read-Host 'Scope'
    $t=Duration
    if(!$t){return}

    $payload = '$ErrorActionPreference = ''SilentlyContinue''' + "`r`n"

    if($s -eq '1' -or $s -eq '3'){
        $payload += ('& "{0}\System32\cscript.exe" //nologo "{0}\System32\slmgr.vbs" /upk' -f $env:SystemRoot) + "`r`n"
        $payload += ('& "{0}\System32\cscript.exe" //nologo "{0}\System32\slmgr.vbs" /cpky' -f $env:SystemRoot) + "`r`n"
    }

    if($s -eq '2' -or $s -eq '3'){
        $o=OSPP
        if($o){
            $id=OfficeKeyId $o
            if($id){
                $payload += ('& "{0}\System32\cscript.exe" //nologo "{1}" /unpkey:{2}' -f $env:SystemRoot,$o,$id) + "`r`n"
            }
        }
    }

    $name='LicenseLab_Expire_'+(Get-Date -Format yyyyMMddHHmmss)
    $payload += ('Unregister-ScheduledTask -TaskName "{0}" -Confirm:$false' -f $name)

    $enc=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($payload))
    $act=New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $enc"
    $tr=New-ScheduledTaskTrigger -Once -At $t
    $set=New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $pr=New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
    $task=New-ScheduledTask -Action $act -Trigger $tr -Settings $set -Principal $pr
    Register-ScheduledTask -TaskName $name -InputObject $task -Force | Out-Null

    Write-Host "Scheduled for $t" -ForegroundColor Green
    Log 'Timer created' $t.ToString()
    P
}
function Repair{while($true){H 'REPAIR';Write-Host '[1] Licensing services [2] Time resync [3] DISM Scan [4] DISM Restore [5] SFC [6] Windows activation settings [7] Office repair [0] Back';switch(Read-Host 'Select'){'1'{foreach($n in @('sppsvc','ClipSVC','LicenseManager')){$s=Get-Service $n -ErrorAction SilentlyContinue;if($s){$s|ft Name,Status,StartType;if($s.Status-ne'Running'){try{Start-Service $n}catch{}}}};P}'2'{w32tm /query /status;w32tm /resync;P}'3'{DISM.exe /Online /Cleanup-Image /ScanHealth;P}'4'{DISM.exe /Online /Cleanup-Image /RestoreHealth;P}'5'{sfc.exe /scannow;P}'6'{Start-Process 'ms-settings:activation'}'7'{Start-Process appwiz.cpl}'0'{return}}}}
function Tech{while($true){H 'TECHNICIAN';Write-Host '[1] System info [2] Export report [3] Service history [4] Logs [5] Configs [0] Back';switch(Read-Host 'Select'){'1'{Get-ComputerInfo|select WindowsProductName,WindowsVersion,OsBuildNumber,CsManufacturer,CsModel,CsProcessors,CsTotalPhysicalMemory|fl;P}'2'{$f=Join-Path $Logs ("report-{0}.txt"-f(Get-Date -Format yyyyMMddHHmmss));"LicenseLab report $(Get-Date)"|Set-Content $f;cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr|Add-Content $f;$o=OSPP;if($o){cscript.exe //nologo $o /dstatus|Add-Content $f};Write-Host $f;P}'3'{Get-ChildItem $Hist|ft Name,LastWriteTime;P}'4'{Start-Process explorer.exe $Logs}'5'{Start-Process explorer.exe $Cfg}'0'{return}}}}
function WinMenu{while($true){H 'WINDOWS';Write-Host '[1] Status [2] Activate [3] Edition [4] Remove key [0] Back';switch(Read-Host 'Select'){'1'{WinStatus}'2'{WinActivate}'3'{WinEdition}'4'{WinRemove}'0'{return}}}}
function OfficeMenu{while($true){H 'OFFICE';Write-Host '[1] Status [2] Activate [3] Remove key [4] Install/Modify [0] Back';switch(Read-Host 'Select'){'1'{OfficeStatus}'2'{OfficeActivate}'3'{OfficeRemove}'4'{InstallModify}'0'{return}}}}
function Main{while($true){H;Write-Host '[1] WINDOWS' -ForegroundColor Green;Write-Host '[2] OFFICE' -ForegroundColor Green;Write-Host '[3] INSTALL / MODIFY' -ForegroundColor Green;Write-Host '[4] LICENSE & TIMER' -ForegroundColor Green;Write-Host '[5] REPAIR' -ForegroundColor Green;Write-Host '[6] TECHNICIAN' -ForegroundColor Green;Write-Host '[0] EXIT';switch(Read-Host 'Select'){'1'{WinMenu}'2'{OfficeMenu}'3'{InstallModify}'4'{Timer}'5'{Repair}'6'{Tech}'0'{return}}}}
if(!(Admin)){Write-Host 'Administrator privileges required. Launch Run-LicenseServiceToolkit.bat.' -ForegroundColor Red;exit 1}
Main

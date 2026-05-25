---
name: apply-changes
description: >
  Full procedures for applying config file and registry changes, and for
  rolling back any change ReFrame has made. Loaded on-demand when the user
  confirms a Change Preview or issues a rollback command.
---

# apply-changes Skill

## Purpose

Provide the complete backup, apply, and rollback procedures for both config
file changes and Windows registry changes. This skill is read when the user
confirms "yes" to a Change Preview, or issues a `rollback` command.

---

## Applying Config File Changes

1. Create backup directory: `C:\Users\<user>\AppData\Local\ReFrame\Backups\<GameName>_<YYYYMMDD_HHmmss>\`
2. Copy original file(s) to backup directory
3. Apply changes using `edit/editFiles`
4. Report each change with old → new value

```powershell
# Create backup directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
# Sanitise game name: strip path separators and reserved filesystem characters
$safeGameName = $GameName -replace '[\\/:*?"<>|]', '_' -replace '\.\.', '_'
$backupDir = "$env:LOCALAPPDATA\ReFrame\Backups\${safeGameName}_${timestamp}"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Copy config files
Copy-Item -Path "<original_path>" -Destination $backupDir -Force
Write-Host "Backup created: $backupDir"
```

---

## Applying Registry Changes

Before writing any registry values, export the affected hives as `.reg` backup
files into the same `%LOCALAPPDATA%\ReFrame\Backups\` root used for config
file backups:

```powershell
# Registry backup — same root as config file backups for one consistent location
$ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$regBackupDir = "$env:LOCALAPPDATA\ReFrame\Backups\registry_$ts"
New-Item -ItemType Directory -Path $regBackupDir -Force | Out-Null
reg export "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"                       "$regBackupDir\PriorityControl.reg" /y
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"  "$regBackupDir\MMCSS.reg" /y
reg export "HKLM\SOFTWARE\Microsoft\Windows\Dwm"                                         "$regBackupDir\DWM.reg" /y
Write-Host "Registry backup written to: $regBackupDir"
```

After the backup, create a `RESTORE-NOTES.txt` in the same folder documenting
every value changed (key path, value name, old value → new value) and the
OverlayTestMode delete caveat (see Rollback section below).

Run as Administrator. Use `Set-ItemProperty` with `-Force`:

```powershell
#Requires -RunAsAdministrator

# NetworkThrottlingIndex — disable network throttling
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force

# SystemResponsiveness — max CPU to foreground
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" -Value 0 -Type DWord -Force

# Games task — GPU priority
$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (-not (Test-Path $gamesPath)) { New-Item -Path $gamesPath -Force | Out-Null }
Set-ItemProperty -Path $gamesPath -Name "GPU Priority"          -Value 8       -Type DWord  -Force
Set-ItemProperty -Path $gamesPath -Name "Priority"              -Value 6       -Type DWord  -Force
Set-ItemProperty -Path $gamesPath -Name "Scheduling Category"   -Value "High"  -Type String -Force
Set-ItemProperty -Path $gamesPath -Name "SFIO Priority"         -Value "High"  -Type String -Force

# Priority separation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
    -Name "Win32PrioritySeparation" -Value 0x26 -Type DWord -Force

# HAGS (Hardware-Accelerated GPU Scheduling)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
    -Name "HwSchMode" -Value 2 -Type DWord -Force

# MPO (Multi-Plane Overlay) — disable to fix stutter on NVIDIA + Windows 11
# NOTE: rollback requires DELETING this value, not setting it to 0.
# The reg export backup above captures the pre-change DWM hive (which lacks this key),
# so importing that backup file correctly restores the default by removing the value.
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" `
    -Name "OverlayTestMode" -Value 5 -Type DWord -Force
```

After applying registry changes, inform the user that **a system restart is
required** for some settings to take effect.

---

## Change Preview Template

Always present this before applying any changes:

```
## Change Preview

The following changes will be made. Type **yes** to apply or **no** to cancel.

### Config file: C:\Users\...\settings.ini
- VSync: 1 → 0
- MaxFPS: 0 → 165
- TextureQuality: 2 → 4

### Registry changes (requires Administrator):
- HKLM\...\SystemProfile → SystemResponsiveness: 20 → 0
- HKLM\...\Tasks\Games → GPU Priority: 2 → 8

### Backup location (all backups — config files and registry):
%LOCALAPPDATA%\ReFrame\Backups\
```

---

## Rollback (`rollback <game name>` or `rollback last`)

List available backups and restore the selected one:

```powershell
$backupRoot = "$env:LOCALAPPDATA\ReFrame\Backups"
Get-ChildItem -Path $backupRoot -Directory -ErrorAction SilentlyContinue |
    Sort-Object CreationTime -Descending |
    Select-Object Name, CreationTime, FullName
```

Present numbered list, confirm selection, restore files, report each restored file.

### Registry Rollback

Registry backups are stored alongside config file backups in
`%LOCALAPPDATA%\ReFrame\Backups\registry_<timestamp>\`. List available
registry backup sets and confirm with the user before restoring:

```powershell
# List available registry backup sets — run elevated
$backupRoot = "$env:LOCALAPPDATA\ReFrame\Backups"
Get-ChildItem -Path $backupRoot -Directory -Filter "registry_*" -ErrorAction SilentlyContinue |
    Sort-Object CreationTime -Descending |
    Select-Object Name, CreationTime, FullName

# Restore the selected set (replace <timestamp> with chosen folder name)
$regBackupDir = "$env:LOCALAPPDATA\ReFrame\Backups\registry_<timestamp>"
reg import "$regBackupDir\PriorityControl.reg"
reg import "$regBackupDir\MMCSS.reg"
reg import "$regBackupDir\DWM.reg"
```

> **OverlayTestMode (MPO) — critical rollback note:**
> Importing the `DWM.reg` file correctly restores the default because the backup
> was taken before `OverlayTestMode` existed — the import removes the value by
> replacing the hive with the pre-change state.
> If for any reason the import is not available, restore with:
>
> ```powershell
> reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /f
> ```
>
> **Do NOT** set `OverlayTestMode` to `0` as a rollback — `0` does not
> re-enable MPO. The value must be absent for Windows to use its built-in
> MPO default.

A reboot is required after registry rollback for `Win32PrioritySeparation`
to take effect.

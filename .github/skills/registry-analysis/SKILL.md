---
name: registry-analysis
description: >
  Assess Windows gaming registry settings and produce a current-vs-recommended
  registry table for ReFrame. Loaded on-demand when the user runs `check registry`
  or when a full optimisation explicitly includes registry review.
---

# registry-analysis Skill

## Purpose

Read and assess the Windows registry settings that affect gaming performance.
Use this skill only when the user runs `check registry` or when a full
optimisation explicitly proceeds into registry review.

---

## Collection commands

```powershell
# Multimedia system profile — gaming
$mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $mmPath) {
    Get-ItemProperty -Path $mmPath | Select-Object NetworkThrottlingIndex, SystemResponsiveness
} else { "[not found] $mmPath" }

# Games task scheduling
$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gamesPath) {
    Get-ItemProperty -Path $gamesPath
} else { "[not found] $gamesPath" }

# Priority separation (foreground boost)
$prioPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
if (Test-Path $prioPath) {
    Get-ItemProperty -Path $prioPath | Select-Object Win32PrioritySeparation
} else { "[not found] $prioPath" }

# Power plan GUID
powercfg /getactivescheme

# Hardware-accelerated GPU scheduling
$hgsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
if (Test-Path $hgsPath) {
    Get-ItemProperty -Path $hgsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
} else { "[not found] $hgsPath" }

# Game Mode / Game Bar
$gmPath = "HKLM:\SOFTWARE\Microsoft\GameBar"
if (Test-Path $gmPath) {
    Get-ItemProperty -Path $gmPath | Select-Object AllowAutoGameMode, AutoGameModeEnabled
} else { "[not found] $gmPath" }

# NVIDIA (if present) — current driver settings location
Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm"
```

---

## Recommended values

| Registry Key / Setting                  | Recommended Value | Effect |
| --------------------------------------- | ----------------- | ------ |
| NetworkThrottlingIndex                  | `ffffffff` (hex)  | Disables network throttling during gameplay |
| SystemResponsiveness                    | `0`               | Allocates max CPU to foreground game |
| Games → GPU Priority                    | `8`               | Raises GPU scheduling priority for game tasks |
| Games → Priority                        | `6`               | Raises CPU scheduling priority for game tasks |
| Games → Scheduling Category             | `High`            | Uses Windows MMCSS High scheduling category |
| Games → SFIO Priority                   | `High`            | Raises storage I/O priority |
| Win32PrioritySeparation                 | `38` (hex 0x26)   | Maximum foreground boost (2 quanta, variable) |
| Power scheme                            | High Performance  | Prevents CPU/GPU throttling during gameplay |
| HwSchMode                               | `2`               | Enables hardware-accelerated GPU scheduling |
| AutoGameModeEnabled / AllowAutoGameMode | `1`               | Enables Windows Game Mode |
| OverlayTestMode (DWM)                   | `5`               | Disables Multi-Plane Overlay (MPO) — eliminates stutter/frame-pacing issues on NVIDIA + Windows 11. **Rollback: value must be DELETED, not set to 0. Setting 0 does not re-enable MPO.** |

---

## Output requirement

Present a registry assessment table with current vs recommended values.
Call out clearly when a value is missing, differs from the recommendation, or
requires Administrator privileges to change.

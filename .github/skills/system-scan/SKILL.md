---
name: system-scan
description: >
  Generates a hardware System Profile for ReFrame by running DxDiag on the fly,
  parsing the resulting XML, and supplementing with targeted PowerShell queries
  for data DxDiag does not cover (storage, power plan). Falls back to a full
  PowerShell-only scan if DxDiag cannot be run. No administrator rights required.
---

# system-scan Skill

## Purpose

Produce a structured **System Profile** containing the hardware and display
context ReFrame needs before making any recommendations. Called at the start
of every `scan system` or `optimise <game>` workflow.

---

## Step 1 — Resolve input source

Choose the source in this order:

1. **User-provided file** — if the user has passed a path with
   `load dxdiag <path>`, read that file directly and skip to Step 3.
2. **Cached file** — if `$env:TEMP\ReFrame-DxDiag.xml` exists and was written
   **after the last system boot**, it is still valid for this session.
   Read it directly and skip to Step 3.
   Skip this check if the user explicitly ran `scan system` — always regenerate
   in that case so a display or HDR change mid-session is picked up.

   ```powershell
   $lastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
   $dxPath   = "$env:TEMP\ReFrame-DxDiag.xml"
   $cacheValid = (Test-Path $dxPath) -and
                 ((Get-Item $dxPath).LastWriteTime -gt $lastBoot)
   ```

3. **Generate on the fly** — run dxdiag now (Step 2).

---

## Step 2 — Generate DxDiag.xml on the fly

No admin rights required. Run in terminal:

```powershell
$dxPath = "$env:TEMP\ReFrame-DxDiag.xml"
Write-Host "Generating DxDiag report — this takes a few seconds..."
$proc = Start-Process -FilePath "dxdiag.exe" `
    -ArgumentList "/whql:off", "/x", "`"$dxPath`"" `
    -PassThru -WindowStyle Hidden
$proc.WaitForExit(30000)   # 30-second timeout

if ((Test-Path $dxPath) -and ((Get-Item $dxPath).Length -gt 1024)) {
    Write-Host "DxDiag report written to: $dxPath"
} else {
    Write-Host "DxDiag generation failed or timed out — falling back to PowerShell scan"
}
```

If the file is present and non-trivially sized (> 1 KB), proceed to Step 3.
If the file is absent or empty, skip to **Step 4 (PowerShell fallback)**.

---

## Step 3 — Parse DxDiag.xml

Read the file with `read/readFile` and extract these fields:

| System Profile field    | XML element (first match)                      | Notes                                                        |
| ----------------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| CPU                     | `SystemInformation > Processor`                |                                                              |
| RAM                     | `SystemInformation > Memory`                   |                                                              |
| OS                      | `SystemInformation > OperatingSystem`          |                                                              |
| GPU name                | `DisplayDevice > CardName`                     | Use first `DisplayDevice` (primary GPU)                      |
| Dedicated VRAM          | `DisplayDevice > DedicatedMemory`              | Strip " MB", divide by 1024 for GB                           |
| Driver version          | `DisplayDevice > DriverVersion`                |                                                              |
| Driver date             | `DisplayDevice > DriverDate`                   |                                                              |
| Current resolution + Hz | `DisplayDevice > CurrentMode`                  | e.g. `5120 x 1440 (32 bit) (240Hz)`                          |
| Native monitor mode     | `DisplayDevice > NativeMode`                   | e.g. `3840 x 1080(p) (120.000Hz)`                            |
| Monitor model           | `DisplayDevice > MonitorModel`                 |                                                              |
| HDR active              | `DisplayDevice > ActiveColorMode`              | `DISPLAYCONFIG_ADVANCED_COLOR_MODE_HDR` = HDR on             |
| VRR support             | `DisplayDevice > MonitorName`                  | Contains `DP_VRR` or `HDMI_VRR` if variable refresh is wired |
| HAGS enabled            | `DisplayDevice > HardwareSchedulingAttributes` | `Enabled:True` = HAGS on; `Enabled:False` = off              |
| DirectX feature level   | `DisplayDevice > FeatureLevels`                | First value, e.g. `12_2` = DX12 Ultimate                     |

After parsing, run these two supplemental PowerShell queries (not in DxDiag):

```powershell
# Storage type — affects streaming pool recommendations
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType

# Active power plan — affects CPU boost and latency
powercfg /getactivescheme
```

Leave the temp file in place — it serves as the session cache (Step 1) so
subsequent `optimise <game>` calls in the same session do not regenerate it.

Proceed to Step 5.

---

## Step 4 — PowerShell fallback scan

Used only when DxDiag generation fails or times out.

```powershell
# CPU
Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

# GPU
Get-CimInstance Win32_VideoController |
    Select-Object Name, AdapterRAM, DriverVersion, VideoProcessor

# RAM
$totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
"Total RAM: $([math]::Round($totalRAM, 1)) GB"
Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity, Speed

# Storage
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, BusType

# OS
Get-CimInstance Win32_OperatingSystem |
    Select-Object Caption, Version, BuildNumber, OSArchitecture

# Power plan
powercfg /getactivescheme

# Windows Game Mode
$gmPath = "HKLM:\SOFTWARE\Microsoft\GameBar"
if (Test-Path $gmPath) {
    Get-ItemProperty -Path $gmPath | Select-Object AllowAutoGameMode, AutoGameModeEnabled
}

# HAGS
$hgsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
if (Test-Path $hgsPath) {
    Get-ItemProperty -Path $hgsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
}
```

Note fields not available in fallback mode (no DxDiag): current display Hz,
native monitor resolution, HDR active status, VRR wiring. State these as
"unknown — run `load dxdiag` for full display data."

---

## Step 5 — Build System Profile output

Present the collected data in this format:

```
## System Profile

| Component   | Details                                         |
| ----------- | ----------------------------------------------- |
| CPU         | [name] — [cores]C/[threads]T @ [GHz]            |
| GPU         | [name] — [VRAM] GB (Driver [version], [date])   |
| RAM         | [total] GB                                      |
| Storage     | [type] — [bus]                                  |
| Display     | [current resolution] @ [Hz] ([monitor model])   |
| Native Mode | [native resolution] @ [Hz]                      |
| HDR         | Active / Supported but off / Not supported       |
| VRR         | Supported (DP_VRR) / Not detected               |
| HAGS        | Enabled / Disabled                              |
| DX Level    | [feature level]                                 |
| OS          | Windows [version] ([build])                     |
| Power Plan  | [plan name]                                     |
```

Then classify the **hardware tier** and store it in session context:

- **High-end**: RTX 4070+ / RX 7800 XT+ / Arc A770+, 32 GB+ RAM
- **Mid-range**: RTX 3060–4060 / RX 6600–7600 / i7/R7 mid-gen, 16 GB RAM
- **Low-end / integrated**: Older cards, integrated graphics, < 16 GB RAM

Every downstream recommendation must be appropriate for this tier.

---

## Notes

- DxDiag temp file is written to `$env:TEMP\ReFrame-DxDiag.xml` and kept as a
  session cache. It is considered valid as long as its `LastWriteTime` is after
  the last system boot — driver updates, HAGS changes, and GPU changes all
  require a reboot, so a post-boot file is safe to reuse.
  The explicit `scan system` command always bypasses this cache to pick up
  display, HDR, or monitor changes that don’t require a reboot.
  Windows does not reliably clean TEMP automatically; the file will persist
  across sessions but will be ignored after a reboot because its write time
  will pre-date the new `LastBootUpTime`.
- `msinfo32.txt` is NOT a valid input. It uses UTF-16 binary encoding and
  contains no additional gaming-relevant data beyond what DxDiag provides.
- If the system has multiple GPUs (integrated + discrete), always use the first
  `DisplayDevice` entry with `DeviceType` = `Full Device (POST)`.

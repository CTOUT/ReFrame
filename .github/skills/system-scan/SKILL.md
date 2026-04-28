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
   **Do not skip this check for `scan system`.** Only bypass the cache if the
   user explicitly asks for a fresh scan with `scan system --fresh` or says
   something like "re-scan", "fresh scan", or "rescan".
   Rationale: hardware does not change mid-session without a reboot, and
   regenerating DxDiag on every `scan system` call adds 10–30 seconds of
   unnecessary latency. If the user suspects a display/HDR change without
   rebooting (rare), they can force a fresh scan explicitly.

   ```powershell
   $lastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
   $dxPath   = "$env:TEMP\ReFrame-DxDiag.xml"
   $cacheValid = (Test-Path $dxPath) -and
                 ((Get-Item $dxPath).LastWriteTime -gt $lastBoot)
   ```

   If the cache is valid, tell the user: *"Using cached hardware profile from
   this session. Run `scan system --fresh` to regenerate."*

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
$proc.WaitForExit(30000)   # wait for dxdiag.exe process to exit (up to 30 s)

# DxDiag writes the XML asynchronously after the process exits.
# Poll until the file exists, is non-trivially sized (> 1 KB),
# and its size has been stable for two consecutive checks.
$maxWait  = 15   # extra seconds to wait after process exit
$waited   = 0
$prevSize = -1
while ($waited -lt $maxWait) {
    Start-Sleep -Milliseconds 500
    $waited += 0.5
    if (Test-Path $dxPath) {
        $size = (Get-Item $dxPath).Length
        if ($size -gt 1024 -and $size -eq $prevSize) { break }  # stable and non-trivial
        $prevSize = $size
    }
}

if ((Test-Path $dxPath) -and ((Get-Item $dxPath).Length -gt 1024)) {
    Write-Host "DxDiag report written to: $dxPath"
} else {
    Write-Host "DxDiag generation failed or timed out — falling back to PowerShell scan"
}
```

If the file is present and non-trivially sized (> 1 KB), proceed to Step 3.
If the file is absent or empty after polling, skip to **Step 4 (PowerShell fallback)**.

---

## Step 3 — Parse DxDiag.xml

Read the file with `read/readFile` and extract these fields:

| System Profile field    | XML path                                                        | Notes                                                        |
| ----------------------- | --------------------------------------------------------------- | ------------------------------------------------------------ |
| CPU                     | `SystemInformation > Processor`                                 |                                                              |
| RAM                     | `SystemInformation > Memory`                                    |                                                              |
| OS                      | `SystemInformation > OperatingSystem`                           |                                                              |
| GPU name                | `DisplayDevices > DisplayDevice > CardName`                     | Use first `DisplayDevice` (primary GPU)                      |
| Dedicated VRAM          | `DisplayDevices > DisplayDevice > DedicatedMemory`              | Strip " MB", divide by 1024 for GB                           |
| Driver version          | `DisplayDevices > DisplayDevice > DriverVersion`                |                                                              |
| Driver date             | `DisplayDevices > DisplayDevice > DriverDate`                   |                                                              |
| Current resolution + Hz | `DisplayDevices > DisplayDevice > CurrentMode`                  | e.g. `5120 x 1440 (32 bit) (240Hz)`                          |
| Native monitor mode     | `DisplayDevices > DisplayDevice > NativeMode`                   | e.g. `3840 x 1080(p) (120.000Hz)`                            |
| Monitor model           | `DisplayDevices > DisplayDevice > MonitorModel`                 |                                                              |
| HDR active              | `DisplayDevices > DisplayDevice > ActiveColorMode`              | `DISPLAYCONFIG_ADVANCED_COLOR_MODE_HDR` = HDR on             |
| VRR support             | `DisplayDevices > DisplayDevice > MonitorName`                  | Contains `DP_VRR` or `HDMI_VRR` if variable refresh is wired |
| HAGS enabled            | `DisplayDevices > DisplayDevice > HardwareSchedulingAttributes` | `Enabled:True` = HAGS on; `Enabled:False` = off              |
| DirectX feature level   | `DisplayDevices > DisplayDevice > FeatureLevels`                | First value, e.g. `12_2` = DX12 Ultimate                     |

After parsing, run these two supplemental PowerShell queries (not in DxDiag):

```powershell
# Storage type — affects streaming pool recommendations
Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName, MediaType, BusType

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
$gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
$gpus | Sort-Object AdapterRAM -Descending | Select-Object -First 1 |
    Select-Object Name, @{N='VRAM_GB';E={[math]::Round($_.AdapterRAM/1GB, 1)}}, DriverVersion, VideoProcessor

# RAM
$totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
"Total RAM: $([math]::Round($totalRAM, 1)) GB"
Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity, Speed

# Storage
Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName, MediaType, Size, BusType

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

Always include the assigned tier in the System Profile output:

```
| Hardware Tier | Mid-range  (override: type "treat as high-end" or "treat as low-end") |
```

If the user says `treat as high-end`, `treat as mid-range`, or `treat as low-end` at any point, update the stored tier immediately and note the override in subsequent recommendations. Never silently reclassify hardware against the user’s stated preference.

Every downstream recommendation must be appropriate for this tier.

---

## Notes

- DxDiag temp file is written to `$env:TEMP\ReFrame-DxDiag.xml` and kept as a
  session cache. It is considered valid as long as its `LastWriteTime` is after
  the last system boot — driver updates, HAGS changes, and GPU changes all
  require a reboot, so a post-boot file is safe to reuse.
  Use the cache for both `scan system` and `optimise <game>` — only bypass it
  when the user explicitly requests a fresh scan (`scan system --fresh`,
  "re-scan", "rescan", or "fresh scan").
  Windows does not reliably clean TEMP automatically; the file will persist
  across sessions but will be ignored after a reboot because its write time
  will pre-date the new `LastBootUpTime`.
- `msinfo32.txt` is NOT a valid input. It uses UTF-16 binary encoding and
  contains no additional gaming-relevant data beyond what DxDiag provides.
- If the system has multiple GPUs (integrated + discrete), always use the first
  `DisplayDevice` entry with `DeviceType` = `Full Device (POST)`.

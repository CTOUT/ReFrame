# Windows Gaming Registry Reference

This document lists the Windows registry keys that ReFrame can read and modify to improve gaming performance.

> **Warning:** Registry edits require Administrator privileges. Always use ReFrame's Change Preview and backup workflow — never edit the registry manually without first understanding the impact.

---

## Multimedia System Profile

Path: `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile`

| Value Name               | Type  | Default | Recommended | Effect                                                        |
| ------------------------ | ----- | ------- | ----------- | ------------------------------------------------------------- |
| `NetworkThrottlingIndex` | DWord | `10`    | `ffffffff`  | Disables Windows' network throttling during game sessions     |
| `SystemResponsiveness`   | DWord | `20`    | `0`         | Allocates maximum CPU resources to the foreground application |

---

## Games Task Scheduling

Path: `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games`

| Value Name            | Type   | Default  | Recommended | Effect                                            |
| --------------------- | ------ | -------- | ----------- | ------------------------------------------------- |
| `GPU Priority`        | DWord  | `2`      | `8`         | Raises the GPU scheduling priority for game tasks |
| `Priority`            | DWord  | `2`      | `6`         | Raises the CPU scheduling priority for game tasks |
| `Scheduling Category` | String | `Medium` | `High`      | Uses the Windows MMCSS High scheduling category   |
| `SFIO Priority`       | String | `Normal` | `High`      | Raises storage I/O priority for game processes    |
| `Affinity`            | DWord  | `0`      | `0`         | Leave at 0 (OS assigns affinity automatically)    |
| `Background Only`     | String | `False`  | `False`     | Must be False for foreground game processes       |

---

## Priority Separation (Foreground Boost)

Path: `HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl`

| Value Name                | Type  | Default | Recommended | Effect                                                |
| ------------------------- | ----- | ------- | ----------- | ----------------------------------------------------- |
| `Win32PrioritySeparation` | DWord | `2`     | `0x26` (38) | Maximum foreground boost: 2 quanta, variable interval |

Decoded values:

| Hex  | Dec | Foreground Boost | Quantum Length | Interval Type |
| ---- | --- | ---------------- | -------------- | ------------- |
| 0x02 | 2   | None (server)    | Short          | Variable      |
| 0x26 | 38  | Maximum (3x)     | Short          | Variable      |
| 0x28 | 40  | Maximum (3x)     | Long           | Fixed         |

---

## Hardware-Accelerated GPU Scheduling (HAGS)

Path: `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`

| Value Name  | Type  | Value | Effect                                                       |
| ----------- | ----- | ----- | ------------------------------------------------------------ |
| `HwSchMode` | DWord | `2`   | Enables HAGS — reduces GPU scheduling latency (Win 10 2004+) |
| `HwSchMode` | DWord | `1`   | Disabled (default on older systems)                          |

> Requires Windows 10 version 2004 or later and a supported GPU driver. A system restart is required after enabling.

---

## Game Mode

Path: `HKLM\SOFTWARE\Microsoft\GameBar`

| Value Name            | Type  | Value | Effect                                           |
| --------------------- | ----- | ----- | ------------------------------------------------ |
| `AllowAutoGameMode`   | DWord | `1`   | Allows Windows to automatically enable Game Mode |
| `AutoGameModeEnabled` | DWord | `1`   | Enables automatic Game Mode activation           |

Game Mode dedicates CPU/GPU resources to the active game and suspends background tasks (Windows Update, indexing, etc.).

---

## Power Plan

Managed via `powercfg`, not a registry key directly.

| Plan                 | GUID                                   | Effect                                                      |
| -------------------- | -------------------------------------- | ----------------------------------------------------------- |
| High Performance     | `8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c` | Prevents CPU/GPU throttling                                 |
| Balanced             | `381b4222-f694-41f0-9685-ff5bb260df2e` | Default; may throttle under sustained load                  |
| Power Saver          | `a1841308-3541-4fab-bc81-f71556f20b4a` | Actively throttles — not suitable for gaming                |
| Ultimate Performance | `e9a42b02-d5df-448d-aa00-03f14749eb61` | Workstation plan; available via `powercfg /duplicatescheme` |

To activate High Performance:

```powershell
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```

---

## Resizable BAR / Smart Access Memory

Not a registry key — configured in UEFI/BIOS firmware.

| Setting               | Where to Enable        | Effect                                     |
| --------------------- | ---------------------- | ------------------------------------------ |
| Resizable BAR (ReBAR) | UEFI → Advanced → PCIe | Allows CPU to access full GPU VRAM at once |
| Smart Access Memory   | AMD UEFI setting name  | AMD's marketing name for ReBAR             |

ReFrame checks for HAGS (which correlates with ReBAR support) but cannot modify BIOS settings. It will flag if ReBAR appears disabled and recommend enabling it in firmware.

---

## References

- [Microsoft MMCSS documentation](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)
- [Microsoft Hardware-Accelerated GPU Scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)
- [Windows power plans reference](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)

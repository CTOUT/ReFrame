# Known Game Configuration Paths

This document lists common configuration file locations for popular games. ReFrame uses these paths when searching for config files.

Paths use environment variable placeholders: `%USERPROFILE%`, `%APPDATA%`, `%LOCALAPPDATA%`, `%PROGRAMFILES%`, `%PROGRAMFILES(X86)%`.

---

## Template

When adding a new game:

```
### Game Name

| Platform | Config Path                                          | Format |
| -------- | ---------------------------------------------------- | ------ |
| Steam    | `%LOCALAPPDATA%\GameName\Config\GameUserSettings.ini` | INI    |

**Key settings:**

| Key             | Effect               | Recommended (mid) | Recommended (high) |
| --------------- | -------------------- | ----------------- | ------------------ |
| ResolutionX     | Horizontal resolution| 1920              | 2560               |

**Notes:** Any caveats, known issues, or version-specific information.
```

---

## Elden Ring

| Platform | Config Path                                                           | Format |
| -------- | --------------------------------------------------------------------- | ------ |
| Steam    | `%APPDATA%\EldenRing\<SteamID64>\GraphicsConfig.xml`                  | XML    |

**Key settings:**

| Key                    | Effect                             | Recommended (mid) | Recommended (high) |
| ---------------------- | ---------------------------------- | ----------------- | ------------------ |
| `ScreenMode`           | 0=windowed, 1=borderless, 2=fullscreen | `2`           | `2`                |
| `AntiAliasing`         | TAA (default), SMAA                | `0` (low TAA)     | `2` (high TAA)     |
| `MotionBlur`           | Enable/disable motion blur         | `0` (off)         | `0` (off)          |
| `Raytracing`           | Enable ray tracing                 | `0`               | `1` (if RTX 3080+) |

**Notes:** Elden Ring does not have a built-in FPS cap; use RTSS or NVIDIA/AMD driver cap to limit to refresh rate.

---

## Cyberpunk 2077

| Platform | Config Path                                                                  | Format |
| -------- | ---------------------------------------------------------------------------- | ------ |
| Steam/GOG| `%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077\UserSettings.json`             | JSON   |
|          | `%USERPROFILE%\AppData\Local\CD Projekt Red\Cyberpunk 2077\`                 |        |

**Key settings (JSON path → value):**

| JSON Key                       | Effect                     | Recommended (mid) | Recommended (high) |
| ------------------------------ | -------------------------- | ----------------- | ------------------ |
| `RayTracing.Enabled`           | Enable ray tracing         | `false`           | `true` (RTX only)  |
| `DLSS.Enabled`                 | Enable DLSS (NVIDIA only)  | `true`            | `true`             |
| `DLSS.DLSSMode`                | DLSS quality mode          | `2` (Balanced)    | `1` (Quality)      |
| `FidelityFX.EnableFSR2`        | Enable FSR 2 (AMD/all)     | `true`            | `false` (use DLSS) |

---

## Counter-Strike 2

| Platform | Config Path                                                                     | Format |
| -------- | ------------------------------------------------------------------------------- | ------ |
| Steam    | `%PROGRAMFILES(X86)%\Steam\userdata\<SteamID>\730\local\cfg\cs2_user.cfg`      | CFG    |
|          | `%PROGRAMFILES(X86)%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\` | CFG |

**Key settings:**

| Setting              | Effect                          | Recommended               |
| -------------------- | ------------------------------- | ------------------------- |
| `fps_max`            | Frame rate cap                  | Match monitor refresh rate|
| `r_dynamic_lighting` | Dynamic lighting quality        | `0` (competitive) / `1`  |
| `mat_queue_mode`     | Async material loading          | `2`                       |

---

## Fortnite

| Platform | Config Path                                                                    | Format |
| -------- | ------------------------------------------------------------------------------ | ------ |
| Epic     | `%LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini`  | INI    |

**Key settings (Unreal Engine 4):**

| Key                            | Effect                         | Recommended (mid) | Recommended (high) |
| ------------------------------ | ------------------------------ | ----------------- | ------------------ |
| `sg.ResolutionQuality`         | Resolution scale (50–100)      | `75`              | `100`              |
| `sg.ShadowQuality`             | Shadow quality (0–3)           | `2`               | `3`                |
| `sg.EffectsQuality`            | Effects quality (0–3)          | `2`               | `3`                |
| `sg.TextureQuality`            | Texture quality (0–3)          | `2`               | `3`                |
| `sg.PostProcessQuality`        | Post process quality (0–3)     | `1`               | `2`                |
| `bShowFPS`                     | Show FPS counter               | `True` (optional) | `True` (optional)  |
| `FrameRateLimit`               | Maximum frame rate             | Monitor Hz        | Monitor Hz         |

---

## Minecraft (Java Edition)

| Platform | Config Path                                           | Format     |
| -------- | ----------------------------------------------------- | ---------- |
| All      | `%APPDATA%\.minecraft\options.txt`                    | Custom KV  |
| All      | `%APPDATA%\.minecraft\config\` (Fabric/Forge mods)   | Various    |

**Key settings:**

| Key              | Effect                        | Recommended (mid) | Recommended (high) |
| ---------------- | ----------------------------- | ----------------- | ------------------ |
| `renderDistance` | Chunk render distance         | `8`               | `16`               |
| `maxFps`         | Frame rate cap                | `120`             | Match refresh rate |
| `guiScale`       | UI scale                      | `2` or `3`        | `3`                |
| `fancyGraphics`  | Fancy vs fast graphics        | `false`           | `true`             |

---

## Fallout 4

| Platform | Config Path                                                              | Format |
| -------- | ------------------------------------------------------------------------ | ------ |
| Steam    | `%USERPROFILE%\Documents\My Games\Fallout4\Fallout4Prefs.ini`            | INI    |
|          | `%USERPROFILE%\Documents\My Games\Fallout4\Fallout4Custom.ini`           | INI    |

**Key settings (`[Display]` section):**

| Key                        | Effect                         | Recommended                  |
| -------------------------- | ------------------------------ | ---------------------------- |
| `iPresentInterval`         | 0 = VSync off, 1 = on          | `0` (use driver sync)        |
| `iSize H` / `iSize W`      | Resolution                     | Match display                |
| `fShadowDistance`          | Shadow draw distance           | `2500`–`4000`                |
| `iShadowMapResolution`     | Shadow map resolution          | `2048` (mid) / `4096` (high) |
| `uExterior Cell Buffer`    | World cell pre-load count      | `36` (default: 36)           |

> **Note:** Always edit `Fallout4Custom.ini` rather than `Fallout4.ini` — the launcher overwrites the base ini on launch.

---

## Adding More Games

Create a pull request adding a new section to this file following the template above. Include:

- Verified config file paths (tested on a real installation)
- Key names confirmed against current game version
- Source citation (official game docs, community wiki, benchmark article)

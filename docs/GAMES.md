# Known Game Configuration Paths

This document lists common configuration file locations for popular games. ReFrame uses these paths when searching for config files.

Paths use environment variable placeholders: `%USERPROFILE%`, `%APPDATA%`, `%LOCALAPPDATA%`, `%PROGRAMFILES%`, `%PROGRAMFILES(X86)%`.

---

## Template

When adding a new game:

```markdown
### Game Name

**Engine:** Unreal Engine 4 / Source / Unity / Custom / Unknown

| Platform | Config Path                                           | Format |
| -------- | ----------------------------------------------------- | ------ |
| Steam    | `%LOCALAPPDATA%\GameName\Config\GameUserSettings.ini` | INI    |

**Key settings:**

| Key         | Effect                | Recommended (mid) | Recommended (high) | Overrides engine default? |
| ----------- | --------------------- | ----------------- | ------------------ | ------------------------- |
| ResolutionX | Horizontal resolution | 1920              | 2560               | No                        |

**Engine overrides:** List any keys where this game's behaviour differs from the engine default.
For each override, explain WHY the engine default is wrong for this game (e.g. reset on launch,
custom scaler, broken implementation, deliberate rebalance by the developer).

**Notes:** Version-specific caveats, known bugs, or other considerations.
```

---

## Ark: Survival Evolved

**Engine:** Unreal Engine 4 (heavily modified)

| Platform | Config Path                                                            | Format |
| -------- | ---------------------------------------------------------------------- | ------ |
| Steam    | `%LOCALAPPDATA%\Ark\Saved\Config\WindowsNoEditor\GameUserSettings.ini` | INI    |
|          | `%LOCALAPPDATA%\Ark\Saved\Config\WindowsNoEditor\Engine.ini`           | INI    |

### Ark: Engine Overrides

Ark ships a heavily customised UE4 scalability and rendering pipeline. Several standard UE4 engine defaults either do not apply, are overwritten on launch, or have been rebalanced by the developers.

| Key                        | UE4 Engine Default  | Ark Behaviour                                      | What to do                                                                                                         |
| -------------------------- | ------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `sg.ResolutionQuality`     | Edit directly       | **Reset on launch** by Ark's graphics menu         | Set via the in-game Graphics slider, not INI. Direct INI edits will be overwritten.                                |
| `sg.ShadowQuality`         | Edit directly       | **Reset on launch** by Ark's graphics menu         | Same — use in-game slider.                                                                                         |
| `sg.TextureQuality`        | Edit directly       | **Reset on launch** by Ark's graphics menu         | Same — use in-game slider.                                                                                         |
| `sg.EffectsQuality`        | Edit directly       | **Reset on launch**                                | Same — use in-game slider.                                                                                         |
| `sg.PostProcessQuality`    | Edit directly       | **Reset on launch**                                | Same — use in-game slider.                                                                                         |
| `bUseVSync`                | `False` recommended | Works as expected in `GameUserSettings.ini`        | Safe to set `False` via INI.                                                                                       |
| `FrameRateLimit`           | Set to monitor Hz   | Works — set in `[/Script/Engine.GameUserSettings]` | Safe to set via INI.                                                                                               |
| `r.Streaming.PoolSize`     | `1000`–`4000`       | Not reset by the game menu — INI edit persists     | Safe to set in `Engine.ini` under `[/Script/Engine.Engine]`. Scale with VRAM.                                      |
| `r.Shadow.RadiusThreshold` | Not exposed         | Not reset — INI edit persists                      | Set in `Engine.ini`. Higher values (e.g. `0.05`) reduce shadow draw calls; lower (e.g. `0.005`) increases quality. |
| `r.DepthOfFieldQuality`    | Not exposed         | Not reset — INI edit persists                      | `0` disables depth-of-field blur (performance gain, especially outdoors).                                          |
| `grass.DensityScale`       | Not exposed         | Not reset — INI edit persists                      | `0.6`–`0.8` (mid) / `1.0` (high). Grass is a significant CPU/GPU cost in Ark.                                      |
| `foliage.DensityScale`     | Not exposed         | Not reset — INI edit persists                      | `0.6`–`0.8` (mid) / `1.0` (high).                                                                                  |

**Key settings (INI-safe — not reset on launch):**

| Key                        | File             | Recommended (mid) | Recommended (high) |
| -------------------------- | ---------------- | ----------------- | ------------------ |
| `bUseVSync`                | GameUserSettings | `False`           | `False`            |
| `FrameRateLimit`           | GameUserSettings | Match monitor Hz  | Match monitor Hz   |
| `r.Streaming.PoolSize`     | Engine.ini       | `2000`            | `4000`             |
| `r.Shadow.RadiusThreshold` | Engine.ini       | `0.03`            | `0.008`            |
| `r.DepthOfFieldQuality`    | Engine.ini       | `0`               | `0`                |
| `grass.DensityScale`       | Engine.ini       | `0.7`             | `1.0`              |
| `foliage.DensityScale`     | Engine.ini       | `0.7`             | `1.0`              |

**Notes:**

- **Two config files matter:** Changes to scalability groups (textures, shadows, effects) must go through the in-game Graphics menu or they will be overwritten. Performance-focused INI tweaks go in `Engine.ini` and are persistent.
- **[/Script/Engine.Engine] section** in `Engine.ini` is where most persistent rendering CVars should be placed.
- Ark's version history matters: some CVars behaved differently before the UE4 upgrade patches (late 2020+). These recommendations are for post-upgrade builds.
- **Sources:** [Ark Official Forums](https://survivetheark.com/), community benchmarks on r/playark.

---

## Elden Ring

| Platform | Config Path                                          | Format |
| -------- | ---------------------------------------------------- | ------ |
| Steam    | `%APPDATA%\EldenRing\<SteamID64>\GraphicsConfig.xml` | XML    |

**Key settings:**

| Key            | Effect                                 | Recommended (mid) | Recommended (high) |
| -------------- | -------------------------------------- | ----------------- | ------------------ |
| `ScreenMode`   | 0=windowed, 1=borderless, 2=fullscreen | `2`               | `2`                |
| `AntiAliasing` | TAA (default), SMAA                    | `0` (low TAA)     | `2` (high TAA)     |
| `MotionBlur`   | Enable/disable motion blur             | `0` (off)         | `0` (off)          |
| `Raytracing`   | Enable ray tracing                     | `0`               | `1` (if RTX 3080+) |

**Notes:** Elden Ring does not have a built-in FPS cap; use RTSS or NVIDIA/AMD driver cap to limit to refresh rate.

---

## Cyberpunk 2077

| Platform  | Config Path                                                      | Format |
| --------- | ---------------------------------------------------------------- | ------ |
| Steam/GOG | `%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077\UserSettings.json` | JSON   |
|           | `%USERPROFILE%\AppData\Local\CD Projekt Red\Cyberpunk 2077\`     |        |

**Key settings (JSON path → value):**

| JSON Key                | Effect                    | Recommended (mid) | Recommended (high) |
| ----------------------- | ------------------------- | ----------------- | ------------------ |
| `RayTracing.Enabled`    | Enable ray tracing        | `false`           | `true` (RTX only)  |
| `DLSS.Enabled`          | Enable DLSS (NVIDIA only) | `true`            | `true`             |
| `DLSS.DLSSMode`         | DLSS quality mode         | `2` (Balanced)    | `1` (Quality)      |
| `FidelityFX.EnableFSR2` | Enable FSR 2 (AMD/all)    | `true`            | `false` (use DLSS) |

---

## Counter-Strike 2

| Platform | Config Path                                                                                 | Format |
| -------- | ------------------------------------------------------------------------------------------- | ------ |
| Steam    | `%PROGRAMFILES(X86)%\Steam\userdata\<SteamID>\730\local\cfg\cs2_user.cfg`                   | CFG    |
|          | `%PROGRAMFILES(X86)%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\` | CFG    |

**Key settings:**

| Setting              | Effect                   | Recommended                |
| -------------------- | ------------------------ | -------------------------- |
| `fps_max`            | Frame rate cap           | Match monitor refresh rate |
| `r_dynamic_lighting` | Dynamic lighting quality | `0` (competitive) / `1`    |
| `mat_queue_mode`     | Async material loading   | `2`                        |

---

## Dead Island 2

**Engine:** Unreal Engine 4 (4.25)

| Platform   | Config Path                                                                              | Format |
| ---------- | ---------------------------------------------------------------------------------------- | ------ |
| Steam      | `%LOCALAPPDATA%\DeadIsland\Saved\Config\WindowsNoEditor\GameUserSettings.ini`            | INI    |
| Epic       | `%LOCALAPPDATA%\DeadIsland\Saved\Config\WindowsNoEditor\GameUserSettings.ini`            | INI    |
| Steam/Epic | `%LOCALAPPDATA%\DeadIsland\Saved\Config\WindowsNoEditor\Engine.ini`                      | INI    |

**Key settings — GameUserSettings.ini (`[/Script/Engine.GameUserSettings]`):**

> ⚠️ DI2 uses a **0–4 scalability range** (not the standard UE4 0–3). Adjusting any setting in the in-game Graphics menu will overwrite `sg.*` values in this file. For persistent overrides, use `Engine.ini` CVars instead.

| Key                       | Effect                              | Recommended (mid) | Recommended (high) |
| ------------------------- | ----------------------------------- | ----------------- | ------------------ |
| `sg.AntiAliasingQuality`  | TAA quality (0–4)                   | `2`               | `4`                |
| `sg.ShadowQuality`        | Shadow quality (0–4)                | `2`               | `4`                |
| `sg.TextureQuality`       | Texture streaming quality (0–4)     | `2`               | `4`                |
| `sg.EffectsQuality`       | Particle and effects quality (0–4)  | `2`               | `4`                |
| `sg.ShadingQuality`       | Material shading complexity (0–4)   | `2`               | `4`                |
| `sg.PostProcessQuality`   | Post-process effects quality (0–4)  | `2`               | `4`                |
| `sg.ViewDistanceQuality`  | LOD and draw distance (0–4)         | `2`               | `4`                |
| `sg.FoliageQuality`       | Foliage density and quality (0–4)   | `2`               | `4`                |
| `sg.SSRQuality`           | Screen-space reflections (0–4)      | `1`               | `4`                |
| `sg.SSAOQuality`          | Ambient occlusion detail (0–4)      | `1`               | `4`                |
| `sg.IndirectShadowQuality`| Capsule shadow quality (0–4)        | `2`               | `4`                |
| `sg.SignificanceQuality`  | Off-screen object significance (0–4)| `2`               | `4`                |
| `bUseVSync`               | In-game VSync                       | `False`           | `False`            |
| `FrameRateLimit`          | Frame rate cap (Hz)                 | Monitor Hz        | Monitor Hz − 3 for VRR |

**Key settings — Engine.ini (`[/Script/Engine.Engine]`):**

| Key                             | Effect                                              | Recommended (mid) | Recommended (high) |
| ------------------------------- | --------------------------------------------------- | ----------------- | ------------------ |
| `r.MotionBlurQuality`           | Motion blur (0 = off)                               | `0`               | `0`                |
| `r.DepthOfFieldQuality`         | Depth of field (0 = off)                            | `0`               | `0`                |
| `r.SceneColorFringeMax`         | Chromatic aberration max intensity (0 = off)        | `0`               | `0`                |
| `r.FilmGrain`                   | Film grain overlay (0 = off)                        | `0`               | `0`                |
| `r.LensFlare`                   | Engine lens flare halos (0 = off)                   | `0`               | `0`                |
| `r.MaxAnisotropy`               | Anisotropic filtering level                         | `8`               | `16`               |
| `r.HZBOcclusion`                | GPU occlusion culling (1 = on)                      | `1`               | `1`                |
| `r.Streaming.PoolSize`          | Texture streaming pool (MB)                         | `2000`            | `8000`             |
| `r.Shadow.RadiusThreshold`      | Min radius for dynamic shadows (lower = more)       | `0.03`            | `0.008`            |
| `r.Shadow.MaxResolution`        | Max shadow map resolution per light                 | `2048`            | `4096`             |
| `r.ReflectionCaptureResolution` | Baked reflection capture resolution                 | `128`             | `256`              |

### Dead Island 2: Engine Overrides

| Key | UE4 Engine Default | DI2 Behaviour | What to do |
| --- | ------------------ | ------------- | ---------- |
| `sg.*` scalability keys | Edit directly in INI | **Overwritten** when the player changes any setting in the in-game Graphics menu | Safe to set via INI, but warn user. For persistent changes use `Engine.ini` CVars directly. |
| FSR 2 | Not present in standard UE4 | DI2 ships FSR 2.1 natively — **known crash bug**: opening the inventory menu while FSR 2 is enabled crashes the game | Always recommend keeping FSR 2 off. Flag the bug if user asks about upscaling. |
| `sg.*` range | 0–3 | DI2 uses **0–4** | Use 0–4 values; do not cap recommendations at 3. |

**Notes:**

- All four post-process comfort settings (`r.MotionBlurQuality`, `r.DepthOfFieldQuality`, `r.SceneColorFringeMax`, `r.FilmGrain`) are recommended off regardless of goal — they are the primary motion sickness and visual fatigue triggers in a first-person melee game.
- At 5120×1440 or higher, increase `r.Streaming.PoolSize` significantly — texture pop-in is more visible at ultrawide/super-ultrawide resolutions.
- FOV (70°–100°), head bob, and camera shake can only be set via the in-game menu.
- **Sources:** [PCGamingWiki — Dead Island 2](https://www.pcgamingwiki.com/wiki/Dead_Island_2), ReFrame live session data.

---

## Fortnite

| Platform | Config Path                                                                   | Format |
| -------- | ----------------------------------------------------------------------------- | ------ |
| Epic     | `%LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini` | INI    |

**Key settings (Unreal Engine 4):**

| Key                     | Effect                     | Recommended (mid) | Recommended (high) |
| ----------------------- | -------------------------- | ----------------- | ------------------ |
| `sg.ResolutionQuality`  | Resolution scale (50–100)  | `75`              | `100`              |
| `sg.ShadowQuality`      | Shadow quality (0–3)       | `2`               | `3`                |
| `sg.EffectsQuality`     | Effects quality (0–3)      | `2`               | `3`                |
| `sg.TextureQuality`     | Texture quality (0–3)      | `2`               | `3`                |
| `sg.PostProcessQuality` | Post process quality (0–3) | `1`               | `2`                |
| `bShowFPS`              | Show FPS counter           | `True` (optional) | `True` (optional)  |
| `FrameRateLimit`        | Maximum frame rate         | Monitor Hz        | Monitor Hz         |

---

## Minecraft (Java Edition)

| Platform | Config Path                                        | Format    |
| -------- | -------------------------------------------------- | --------- |
| All      | `%APPDATA%\.minecraft\options.txt`                 | Custom KV |
| All      | `%APPDATA%\.minecraft\config\` (Fabric/Forge mods) | Various   |

**Key settings:**

| Key              | Effect                 | Recommended (mid) | Recommended (high) |
| ---------------- | ---------------------- | ----------------- | ------------------ |
| `renderDistance` | Chunk render distance  | `8`               | `16`               |
| `maxFps`         | Frame rate cap         | `120`             | Match refresh rate |
| `guiScale`       | UI scale               | `2` or `3`        | `3`                |
| `fancyGraphics`  | Fancy vs fast graphics | `false`           | `true`             |

---

## Fallout 4

| Platform | Config Path                                                    | Format |
| -------- | -------------------------------------------------------------- | ------ |
| Steam    | `%USERPROFILE%\Documents\My Games\Fallout4\Fallout4Prefs.ini`  | INI    |
|          | `%USERPROFILE%\Documents\My Games\Fallout4\Fallout4Custom.ini` | INI    |

**Key settings (`[Display]` section):**

| Key                     | Effect                    | Recommended                  |
| ----------------------- | ------------------------- | ---------------------------- |
| `iPresentInterval`      | 0 = VSync off, 1 = on     | `0` (use driver sync)        |
| `iSize H` / `iSize W`   | Resolution                | Match display                |
| `fShadowDistance`       | Shadow draw distance      | `2500`–`4000`                |
| `iShadowMapResolution`  | Shadow map resolution     | `2048` (mid) / `4096` (high) |
| `uExterior Cell Buffer` | World cell pre-load count | `36` (default: 36)           |

> **Note:** Always edit `Fallout4Custom.ini` rather than `Fallout4.ini` — the launcher overwrites the base ini on launch.

---

## Adding More Games

Create a pull request adding a new section to this file following the template above. Include:

- Verified config file paths (tested on a real installation)
- Key names confirmed against current game version
- Source citation (official game docs, community wiki, benchmark article)

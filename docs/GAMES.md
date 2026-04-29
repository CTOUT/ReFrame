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

## Apex Legends

**Engine:** Source (Modified — Respawn/Titanfall)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam / EA App | `%USERPROFILE%\Saved Games\Respawn\Apex Legends\Local\videoconfig.txt` | JSON key-value |
| Steam / EA App | `%USERPROFILE%\Saved Games\Respawn\Apex Legends\Local\autoexec.cfg` | CFG |

**Key settings — videoconfig.txt:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `setting.fullscreen` | Display mode (0=windowed, 1=fullscreen, 2=borderless) | `1` | `1` | `1` |
| `setting.gpu_mem_level` | Texture quality (0=low, 1=med, 2=high) | `0` | `1` | `2` |
| `setting.shadow_detail` | Shadow quality (0=low, 1=med, 2=high) | `0` | `1` | `2` |
| `setting.csm_enabled` | Cascaded shadow maps (0=off, 1=on) | `0` | `1` | `1` |
| `setting.ssao_enabled` | Ambient occlusion (0=off, 1=on) | `0` | `0` | `1` |
| `setting.model_quality` | Model detail (0=low, 1=med, 2=high) | `0` | `1` | `2` |

**Key settings — autoexec.cfg (console vars, create if absent):**

| Key | Effect | Recommendation |
| --- | ------ | -------------- |
| `fps_max` | Frame rate cap | Monitor Hz + 10 |
| `cl_showfps 4` | Detailed FPS + frame time overlay | Optional |

**Notes:**
- Apex runs EasyAntiCheat. Both config files are EAC-safe.
- Uncapped FPS in lobby/menus causes runaway GPU heat — always set `fps_max` in autoexec.cfg.
- Disabling `setting.csm_enabled` alongside `setting.shadow_detail 0` is the competitive standard for maximum consistent frame time.
- NVIDIA Reflex is available in Settings > Video — enable + Boost for measurable input lag reduction.
- **Sources:** [PCGamingWiki — Apex Legends](https://www.pcgamingwiki.com/wiki/Apex_Legends)

---

## Baldur's Gate 3

**Engine:** Divinity Engine 4.0 (Larian Studios)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam / GOG | `%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public\config.lsx` | LSX (XML-like) |

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `TextureQuality` | Texture resolution (0=low … 3=ultra) | `1` | `2` | `3` |
| `ShadowQuality` | Shadow quality (0=low … 3=ultra) | `1` | `2` | `3` |
| `SSAOEnabled` | Ambient occlusion (0=off, 1=on) | `0` | `1` | `1` |
| `Bloom` | Bloom post-process (0=off, 1=on) | `0` | `1` | `1` |
| `SSREnabled` | Screen-space reflections (0=off, 1=on) | `0` | `0` | `1` |

**Notes:**
- Act 2 (Shadow-Cursed Lands) is the most GPU-expensive area — shadow quality is the primary lever. Expect 20–40% lower FPS vs Act 1 at the same settings.
- Act 3 (Lower City) has high VRAM pressure. Users with < 8 GB VRAM should reduce TextureQuality to 1.
- DLSS 3 (RTX) and FSR (AMD/all) are available in Settings > Display. FSR 1.0 is the only FSR version available — quality is noticeably lower than FSR 2+.
- Patch 5/7 significantly improved CPU performance in the Lower City.
- **Sources:** [PCGamingWiki — Baldur's Gate 3](https://www.pcgamingwiki.com/wiki/Baldur%27s_Gate_3)

---

## Call of Duty: Black Ops 6

**Engine:** IW Engine 9 (Treyarch / Infinity Ward)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam / Battle.net / Xbox App | `%LOCALAPPDATA%\Activision\Call of Duty\players\config.cfg` | CFG (Quake-style `seta`) |

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `seta r_textureQuality` | Texture quality (0=low … 3=ultra) | `1` | `2` | `3` |
| `seta r_shadowQuality` | Shadow quality (0=low … 3=ultra) | `0` | `1` | `2` |
| `seta r_ssao` | Ambient occlusion (0=off, 1=on) | `0` | `1` | `1` |
| `seta r_reflections` | Screen-space reflections (0=low … 3=ultra) | `0` | `1` | `2` |
| `seta com_maxfps` | Frame rate cap (0=unlimited) | Monitor Hz | Monitor Hz | Monitor Hz |
| `seta r_filmUseToneMap` | Film-style tone mapping (0=off, 1=on) | `0` | `1` | `1` |

**Notes:**
- Config is protected by Ricochet anti-cheat. All keys listed here are Ricochet-safe.
- BO6 introduced Omnimovement — a wider FOV (100–110) aids tracking the faster omnidirectional movement.
- `r_filmUseToneMap 0` brightens mid-tones, improving visibility of enemies in dark areas — common competitive choice.
- DLSS 4 (RTX), FSR 4, and XeSS are available in-game under Graphics > Upscaling.
- **Sources:** [PCGamingWiki — Call of Duty: Black Ops 6](https://www.pcgamingwiki.com/wiki/Call_of_Duty:_Black_Ops_6)

---

## Dota 2

**Engine:** Source 2 (Valve — shares engine with CS2)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%PROGRAMFILES(X86)%\Steam\userdata\<SteamID>\570\local\cfg\video.txt` | Valve video.txt |
| Steam | `%PROGRAMFILES(X86)%\Steam\steamapps\common\dota 2 beta\game\dota\cfg\autoexec.cfg` | CFG |

> **Note:** The install directory is named `dota 2 beta` even for the retail release.

**Key settings — video.txt:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `setting.gpu_mem_level` | Texture quality (0=low … 3=ultra) | `0` | `2` | `3` |
| `setting.shadow_quality` | Shadow quality (0=low … 3=ultra) | `0` | `1` | `3` |
| `setting.ambient_occlusion` | Ambient occlusion (0=off, 1=on) | `0` | `0` | `1` |
| `setting.antialias_mode` | Anti-aliasing mode (0–8) | `0` | `2` | `6` |
| `setting.water_quality` | Water rendering quality (0–2) | `0` | `1` | `2` |

**Notes:**
- Dota 2 is CPU-bound during complex teamfights (Roshan fights, high-level tournaments). GPU settings have limited impact during peak combat moments — CPU optimisation matters more.
- Vulkan launch option (`-vulkan`) can improve CPU overhead on some systems; add via Steam > Properties > Launch Options.
- **Sources:** [PCGamingWiki — Dota 2](https://www.pcgamingwiki.com/wiki/Dota_2)

---

## Enshrouded

**Engine:** Keen Engine (Keen Games)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%USERPROFILE%\AppData\Local\Keen Games\Enshrouded\graphics.cfg` | CFG (key=value) |

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `ResolutionScale` | Render resolution % (50–100) | `75` | `90` | `100` |
| `ShadowQuality` | Shadow quality (0=low … 3=ultra) | `1` | `2` | `3` |
| `TextureQuality` | Texture resolution (0=low … 3=ultra) | `1` | `2` | `3` |
| `FoliageDensity` | Foliage density (0=low … 3=ultra) | `1` | `2` | `3` |
| `VolumetricFog` | Volumetric fog (0=off, 1=low, 2=high) | `0` | `1` | `2` |

**Notes:**
- The Shroud (the game's signature fog-of-curse mechanic) is a significant GPU cost area — volumetric fog and particle effects are heavier inside Shroud zones. Expect 10–30% lower FPS in Shroud vs clear-sky areas.
- Enshrouded supports dedicated multiplayer servers up to 24 players. Simulation load scales with player count.
- DLSS (NVIDIA), FSR (AMD), and XeSS (Intel) are available in Settings > Graphics > Upscaling.
- **Sources:** [PCGamingWiki — Enshrouded](https://www.pcgamingwiki.com/wiki/Enshrouded)

---

## Fortnite

**Engine:** Unreal Engine 5 (Epic Games — custom build)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Epic Games Store | `%LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini` | INI |
| Epic Games Store | `%LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient\Engine.ini` | INI |

**Key settings — GameUserSettings.ini (`[/Script/FortniteGame.FortGameUserSettings]`):**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `sg.ShadowQuality` | Shadow quality (0–3) | `0` | `1` | `3` |
| `sg.TextureQuality` | Texture quality (0–3) | `1` | `2` | `3` |
| `sg.EffectsQuality` | Effects quality (0–3) | `1` | `2` | `3` |
| `sg.PostProcessQuality` | Post-process quality (0–3) | `0` | `1` | `3` |
| `sg.ViewDistanceQuality` | View distance (0–3) | `1` | `2` | `3` |
| `FrameRateLimit` | Frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |

**Notes:**
- Epic resets some `sg.*` values to defaults in seasonal patches — verify settings after each major update.
- **Lumen** (UE5 global illumination) is available in Performance settings but is server-side controlled per match type — cannot be forced on in standard modes.
- Performance Mode (DX11 renderer) in Settings > Video > Rendering Mode offers a significant FPS improvement on lower-end hardware at the cost of visual quality.
- **Sources:** [PCGamingWiki — Fortnite](https://www.pcgamingwiki.com/wiki/Fortnite)

---

## Grand Theft Auto V

**Engine:** RAGE (Rockstar Advanced Game Engine 5.x)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%USERPROFILE%\Documents\Rockstar Games\GTA V\settings.xml` | XML |
| Epic Games Store | `%USERPROFILE%\Documents\Rockstar Games\GTA V\settings.xml` | XML |
| Rockstar Launcher | `%USERPROFILE%\Documents\Rockstar Games\GTA V\settings.xml` | XML |

**Key settings:**

| Key (XML attribute) | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `TextureQuality` | Texture quality (0=normal, 1=high, 2=very high) | `0` | `1` | `2` |
| `ShaderQuality` | Shader complexity (0=normal, 1=high, 2=very high) | `0` | `1` | `2` |
| `ShadowQuality` | Shadow quality (0=off, 1=normal, 2=high, 3=very high, 4=ultra) | `1` | `2` | `4` |
| `ReflectionQuality` | Reflection quality (0–3) | `0` | `1` | `3` |
| `GrassQuality` | Grass detail (0=off, 1=normal, 2=high, 3=ultra) | `0` | `1` | `3` |
| `PostFX` | Post-processing effects (0=off, 1=normal, 2=high, 3=ultra) | `1` | `2` | `3` |
| `MotionBlurStrength` | Motion blur intensity (0.0–1.0) | `0` | `0` | `0` |

**Notes:**
- `settings.xml` is overwritten by the in-game Graphics menu. Edit only while GTA V is fully closed.
- Population Density and Population Variety (pedestrian and vehicle count) are significant CPU cost levers — only adjustable in-game.
- The 2022 Enhanced Edition added DLSS 3, FSR 2, and ray tracing on PC.
- **Sources:** [PCGamingWiki — Grand Theft Auto V](https://www.pcgamingwiki.com/wiki/Grand_Theft_Auto_V)

---

## League of Legends

**Engine:** Riot Engine (custom)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Riot Games Launcher | `%USERPROFILE%\Documents\League of Legends\Config\game.cfg` | INI |
| Riot Games Launcher | `%USERPROFILE%\Documents\League of Legends\Config\PersistedSettings.json` | JSON |

**Key settings — game.cfg:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `WindowMode` | Display mode (0=windowed, 1=borderless, 2=fullscreen) | `2` | `2` | `2` |
| `ShadowQuality` | Shadow quality (0=off, 1=low, 2=med, 3=high) | `0` | `1` | `3` |
| `EnvironmentQuality` | Environment detail (0–3) | `0` | `1` | `3` |
| `EffectsQuality` | Spell/particle effects (0–3) | `0` | `1` | `3` |
| `CharacterQuality` | Champion model detail (0–3) | `1` | `2` | `3` |
| `fps_cap_value` | Frame rate cap (fps_cap must = Custom) | Monitor Hz | Monitor Hz | Monitor Hz |

**Notes:**
- League of Legends is CPU-bound; the GPU is rarely the bottleneck except at maximum quality settings or 4K.
- ARAM has significantly more on-screen ability effects than Summoner's Rift — `EffectsQuality` is the most impactful setting in ARAM specifically.
- Colourblind mode is available in Accessibility settings (in-game only) — an important accessibility consideration.
- **Sources:** [PCGamingWiki — League of Legends](https://www.pcgamingwiki.com/wiki/League_of_Legends)

---

## Marvel Rivals

**Engine:** Unreal Engine 5 (NetEase)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%LOCALAPPDATA%\MarvelRivals\Saved\Config\Windows\GameUserSettings.ini` | INI |
| Steam | `%LOCALAPPDATA%\MarvelRivals\Saved\Config\Windows\Engine.ini` | INI |

**Key settings — GameUserSettings.ini:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `sg.ShadowQuality` | Shadow quality (0–3) | `0` | `1` | `3` |
| `sg.TextureQuality` | Texture quality (0–3) | `1` | `2` | `3` |
| `sg.EffectsQuality` | Particle/effects quality (0–3) | `0` | `1` | `3` |
| `sg.PostProcessQuality` | Post-process effects (0–3) | `0` | `1` | `3` |
| `sg.ViewDistanceQuality` | View distance (0–3) | `1` | `2` | `3` |
| `FrameRateLimit` | Frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |

**Notes:**
- `sg.EffectsQuality 0` is the most impactful performance setting. Marvel Rivals has extremely high particle density from hero abilities — effects quality directly affects frame time consistency during teamfights.
- DLSS 4 Multi-Frame Generation (RTX), FSR 4, and XeSS are available in-game. These are the primary recommended optimisation path on capable hardware.
- Per-hero VFX reduction (in-game > Accessibility > Reduce Particle Effects) can further reduce visual noise without affecting core settings.
- **Sources:** [PCGamingWiki — Marvel Rivals](https://www.pcgamingwiki.com/wiki/Marvel_Rivals)

---

## Minecraft (Java Edition)

**Engine:** Minecraft Java Engine (JVM-based)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Official Launcher | `%APPDATA%\.minecraft\options.txt` | Key:value (colon-separated) |
| Third-party launchers | `<instance_dir>\.minecraft\options.txt` | Key:value |

> **Note:** Third-party launchers (Prism, MultiMC, ATLauncher) use isolated instance directories. Each instance has its own `options.txt`.

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `renderDistance` | Chunk render distance (2–32 chunks) | `8` | `12` | `16` |
| `simulationDistance` | Chunk simulation distance (5–32; separate from render since 1.18) | `6` | `10` | `12` |
| `maxFps` | Frame rate cap (260=unlimited) | Monitor Hz+10 | Monitor Hz+10 | Monitor Hz+10 |
| `graphicsMode` | Rendering quality (0=fast, 1=fancy, 2=fabulous) | `0` | `1` | `1` |
| `particles` | Particle density (0=all, 1=decreased, 2=minimal) | `2` | `1` | `0` |
| `entityDistanceFactor` | Entity render distance multiplier | `0.5` | `1.0` | `1.0` |
| `mipmapLevels` | Mipmap filtering (0=off, 4=max) | `4` | `4` | `4` |
| `ao` | Ambient occlusion (0=off, 1=on) | `0` | `1` | `1` |

**JVM arguments (set in launcher):**

| Argument | Recommendation |
| -------- | -------------- |
| `-Xmx` | 4–6 GB vanilla; 6–8 GB modded |
| `-Xms` | Match `-Xmx` to prevent heap resize stutters |
| Aikar's G1GC flags | Apply at all tiers — eliminates GC-pause stutters; see [aikar.co/mcflags.html](https://aikar.co/mcflags.html) |

**Recommended performance mods (Fabric):**

| Mod | Effect |
| --- | ------ |
| Sodium | Replaces renderer; typically 2–5× FPS vs vanilla |
| Lithium | Server-side logic optimisation (pathfinding, AI, chunk ticking) |
| Iris Shaders | Shader pack support for Sodium-based installs |

**Notes:**
- `renderDistance` is by far the dominant performance variable — more impactful than all GPU settings combined.
- `simulationDistance` can be set lower than `renderDistance` without visual impact; distant chunks render but don't tick.
- Minecraft Java Edition with Sodium is a fundamentally different performance profile from vanilla.
- **Sources:** [Minecraft Wiki — Options.txt](https://minecraft.wiki/w/Options.txt), [Aikar JVM flags](https://aikar.co/mcflags.html)

---

## PUBG: Battlegrounds

**Engine:** Unreal Engine 4

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%LOCALAPPDATA%\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini` | INI |
| Steam | `%LOCALAPPDATA%\TslGame\Saved\Config\WindowsNoEditor\Engine.ini` | INI |

> **Note:** The internal project name is `TslGame` — all config paths use this name regardless of display name.

**Key settings — GameUserSettings.ini:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `sg.TextureQuality` | Texture quality (0–3) | `1` | `2` | `3` |
| `sg.ShadowQuality` | Shadow quality (0–3) | `0` | `1` | `3` |
| `sg.EffectsQuality` | Effects quality (0–3) | `1` | `2` | `3` |
| `sg.PostProcessQuality` | Post-process quality (0–3) | `0` | `1` | `3` |
| `sg.ViewDistanceQuality` | View distance (0–3) | `2` | `3` | `3` |
| `FrameRateLimit` | Frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |

**Key settings — Engine.ini:**

| Key | Effect | Recommendation |
| --- | ------ | -------------- |
| `r.MotionBlurQuality=0` | Disable motion blur | All tiers |
| `r.DepthOfFieldQuality=0` | Disable depth of field | All tiers |

**Notes:**
- BattlEye anti-cheat does not scan config INI files. All keys listed are BattlEye-safe.
- `sg.FoliageQuality` is intentionally omitted — low foliage reduces grass cover used for concealment and provides an unfair competitive advantage.
- `sg.ViewDistanceQuality` should stay at 2+ — reducing it causes enemies to pop in at close range.
- **Sources:** [PCGamingWiki — PUBG: Battlegrounds](https://www.pcgamingwiki.com/wiki/PUBG:_Battlegrounds)

---

## Rust

**Engine:** Unity

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | `%APPDATA%\Roaming\Rust\client.cfg` | CFG (key value) |

> **Note:** `client.cfg` is the authoritative config source. The in-game settings menu writes here. Edit only while Rust is fully closed.

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `graphics.quality` | Overall quality preset (0–5) | `1` | `3` | `5` |
| `graphics.shaderlod` | Shader detail (100–600) | `100` | `400` | `600` |
| `graphics.shadow_cascades` | Shadow cascades (0=off, 1=low, 2=high) | `0` | `1` | `2` |
| `graphics.shadow_distance` | Shadow draw distance (10–400) | `40` | `150` | `400` |
| `graphics.terrain_quality` | Terrain detail (50–200) | `50` | `100` | `200` |
| `gfx-enable-gfx-jobs` | Multi-threaded rendering jobs (0=off, 1=on) | `1` | `1` | `1` |
| `gfx-enable-native-gfx-jobs` | Native GPU job scheduling (0=off, 1=on) | `1` | `1` | `1` |

**Notes:**
- `gfx-enable-gfx-jobs 1` and `gfx-enable-native-gfx-jobs 1` should be enabled at all tiers — 20–40% FPS gain on 6+ core CPUs with negligible downside.
- `graphics.shadow_distance 40` (performance) eliminates shadow rendering overhead almost entirely. Competitive players commonly use 40–80.
- Max Gibs (`grass.forceredraw`): the ragdoll/giblet cap progressively degrades performance over a long session as the limit accumulates. Reduce in-game if FPS degresses over time.
- EasyAntiCheat does not scan `client.cfg`. All keys listed are EAC-safe.
- **Sources:** [PCGamingWiki — Rust](https://www.pcgamingwiki.com/wiki/Rust)

---

## Valheim

**Engine:** Unity

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam | Windows registry: `HKCU\Software\IronGate\Valheim\` | Registry (PlayerPrefs) |
| Steam | `%APPDATA%\..\LocalLow\IronGate\Valheim\boot.config` | boot.config |

> **Note:** Valheim uses Unity's PlayerPrefs system — settings are stored in the Windows registry under a hashed key, not a flat file. The in-game settings menu writes to this location. `boot.config` accepts Unity command-line args evaluated at startup.

**Key settings — boot.config:**

| Key | Effect | Recommendation |
| --- | ------ | -------------- |
| `gfx-enable-gfx-jobs=1` | Multi-threaded rendering jobs | All tiers — 20–40% FPS gain on 6+ core CPUs |
| `gfx-enable-native-gfx-jobs=1` | Native GPU job scheduling | All tiers |

**In-game settings (written to registry via Unity PlayerPrefs):**

| Setting | Effect | Performance | Balanced | Quality |
| ------- | ------ | ----------- | -------- | ------- |
| Shadow Quality | Shadow detail | Low | Medium | High |
| Shadow Distance | Shadow draw distance | 40 | 80 | 150 |
| LOD Bias | Level-of-detail aggressiveness | 1.0 | 2.0 | 3.0 |
| Terrain Quality | Terrain mesh detail | Low | Medium | High |

**Notes:**
- The most impactful optimisation is adding `gfx-enable-gfx-jobs=1` and `gfx-enable-native-gfx-jobs=1` to `boot.config` — significant FPS gain on multi-core CPUs from Valheim's Unity build.
- Performance varies significantly by biome: Mistlands (dense procedural fog) and Plains (open terrain + high entity count) are the heaviest biomes. Mistlands specifically causes GPU pressure from fog shaders.
- **Sources:** [PCGamingWiki — Valheim](https://www.pcgamingwiki.com/wiki/Valheim)

---

## Valorant

**Engine:** Unreal Engine 4 (Riot Games custom build)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Riot Games Launcher | `%LOCALAPPDATA%\VALORANT\Saved\Config\Windows\GameUserSettings.ini` | INI |
| Riot Games Launcher | `%LOCALAPPDATA%\VALORANT\Saved\Config\Windows\Engine.ini` | INI |

> **Note:** The `Windows` subdirectory matches the Windows platform code, not a user folder.

**Key settings — GameUserSettings.ini:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `sg.TextureQuality` | Texture quality (0–3) | `0` | `2` | `3` |
| `sg.ShadowQuality` | Shadow quality (0–3) | `0` | `1` | `3` |
| `sg.EffectsQuality` | Effects quality (0–3) | `0` | `1` | `3` |
| `sg.PostProcessQuality` | Post-process quality (0–3) | `0` | `1` | `3` |
| `FrameRateLimit` | Frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |

**Notes:**
- Valorant is CPU-bound, not GPU-bound. GPU settings have limited impact on frame rate for most users — CPU and `FrameRateLimit` matter more.
- Vanguard anti-cheat does not scan INI config files. All keys listed are Vanguard-safe.
- Vanguard requires TPM 2.0 and Secure Boot on Windows 11. If the game fails to launch, check BIOS settings.
- NVIDIA Reflex is available in Settings > Video. Strongly recommended — Valorant is latency-sensitive.
- **Sources:** [PCGamingWiki — Valorant](https://www.pcgamingwiki.com/wiki/Valorant)

---

## Warframe

**Engine:** Evolution Engine (Digital Extremes)

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Steam / Epic / Standalone | `%LOCALAPPDATA%\Warframe\EE.cfg` | CFG (key=value) |

> **Note:** `EE.cfg` is rewritten on every game exit. Edit only while Warframe is fully closed and verify changes were not overwritten on next launch.

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `Graphics.RenderSpec` | Quality preset (0=low … 3=ultra) | `1` | `2` | `3` |
| `Graphics.ShadowQuality` | Shadow quality (0=off … 4=ultra) | `0` | `2` | `4` |
| `Graphics.TextureStreaming` | Texture streaming (0=off, 1=on) | `0` | `1` | `0` |
| `Graphics.ParticleSystem` | Particle quality (0=low, 1=med, 2=high) | `0` | `1` | `2` |
| `Graphics.DX11` | DX11 renderer (0=DX10, 1=DX11) | `1` | `1` | `1` |
| `Graphics.RefreshRate` | Frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |

**Notes:**
- `Graphics.ParticleSystem` is the most impactful setting for endgame content (Steel Path, Arbitrations, Netracells) — Warframe abilities produce extreme particle density. High particle quality in late-game missions can cause severe frame drops.
- `Graphics.TextureStreaming 0` (off) on 16 GB+ RAM + fast SSD eliminates mid-mission texture pop-in at the cost of longer initial load times.
- `EE.cfg` overwrite: always verify settings survive a game restart before assuming the edit persisted.
- DLSS (since 2022) and FSR (since 2021) are available in Options > Display > Upscaling.
- **Sources:** [PCGamingWiki — Warframe](https://www.pcgamingwiki.com/wiki/Warframe), [Warframe Wiki — EE.cfg](https://warframe.fandom.com/wiki/EE.cfg)

---

## World of Warcraft

**Engine:** Blizzard WoW Engine

| Platform | Config Path | Format |
| -------- | ----------- | ------ |
| Battle.net (Retail) | `%APPDATA%\Battle.net\WTF\Config.wtf` | WTF (key "value") |
| Battle.net (Classic) | `%APPDATA%\Battle.net\WoW Classic\WTF\Config.wtf` | WTF |
| Battle.net (PTR) | `%APPDATA%\Battle.net\WoW Public Test\WTF\Config.wtf` | WTF |

> **Note:** `Config.wtf` is reset to defaults if the game client detects file corruption or version mismatch. Keep a backup copy.

**Key settings:**

| Key | Effect | Performance | Balanced | Quality |
| --- | ------ | ----------- | -------- | ------- |
| `SET gxTextureLodBias` | Texture mipmap bias (lower = sharper; -3 to 3) | `0` | `-1` | `-3` |
| `SET graphicsSpellDensity` | Spell visual density in group content (1–10) | `3` | `5` | `10` |
| `SET shadowMode` | Shadow quality (0=off, 1=on) | `1` | `1` | `1` |
| `SET shadowTextureSize` | Shadow map resolution (512–4096) | `512` | `1024` | `2048` |
| `SET farclip` | View distance (177–2133) | `400` | `1000` | `2133` |
| `SET environmentDetail` | Environment detail density (0.5–2.0) | `0.5` | `1.0` | `2.0` |
| `SET waterDetail` | Water rendering quality (0–3) | `0` | `2` | `3` |
| `SET SSAO` | Ambient occlusion (0=off, 1=on) | `0` | `1` | `1` |
| `SET maxFPS` | Foreground frame rate cap | Monitor Hz | Monitor Hz | Monitor Hz |
| `SET maxFPSbk` | Background frame rate cap | `30` | `30` | `30` |

**Notes:**
- `graphicsSpellDensity` is the single most impactful setting for raid performance — high-end raid encounters (Mythic) have hundreds of simultaneous spell effects. Value 3 is the competitive standard in progression raiding.
- `maxFPSbk 30` ensures WoW does not consume full GPU resources when alt-tabbed.
- DLSS 4 and FSR 3.1 are available in System > Advanced. Setting a "Raid" graphics preset (lower `graphicsSpellDensity`) vs a "World/Questing" preset is a common practice.
- **Sources:** [PCGamingWiki — World of Warcraft](https://www.pcgamingwiki.com/wiki/World_of_Warcraft), [Wowpedia — Config.wtf](https://wowpedia.fandom.com/wiki/Config.wtf)

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

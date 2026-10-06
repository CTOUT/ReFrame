---
name: config-profiles
description: >
  Procedures for creating, listing, diffing, and switching named game configuration
  profiles. Handles multi-monitor setups, streaming and remote play (Steam Link,
  Moonlight), and competitive presets with process safety verification and pre-switch snapshots.
---

# config-profiles Skill

## Purpose

Provide the complete workflow for saving, listing, diffing, and switching named configuration
profiles for games. This allows users to seamlessly move between different gaming contexts:

- **Display switching** (e.g. desktop 5120×1440 or 4K vs. 1080p/1440p secondary monitor or TV)
- **Streaming and remote play** (e.g. Steam Link, Moonlight, or handheld streaming at 1080p/720p 60 FPS)
- **Playstyle presets** (e.g. _Competitive Mode_ for lowest latency and maximum clarity vs. _Cinematic Mode_ for maximum visual fidelity)

---

## Profile Storage Architecture

Named profiles are stored under the user's local ReFrame directory, alongside backups:

```text
%LOCALAPPDATA%\ReFrame\
├── Backups\
│   └── <Game>_<timestamp>\
└── Profiles\
    └── <SanitizedGameName>\
        ├── <ProfileName>\
        │   ├── profile.json               (metadata descriptor)
        │   └── <config_file(s)>           (e.g. GameUserSettings.ini, UserSettings.json)
        └── <AnotherProfile>\
            ├── profile.json
            └── <config_file(s)>
```

### `profile.json` Schema

Every saved profile contains a `profile.json` metadata descriptor:

```json
{
  "profile_name": "steam-link-1080p",
  "game": "Cyberpunk 2077",
  "created": "2026-10-04T15:00:00Z",
  "updated": "2026-10-04T15:00:00Z",
  "target_display": {
    "resolution": "1920x1080",
    "refresh_rate": 60,
    "aspect_ratio": "16:9"
  },
  "optimisation_goal": "balanced",
  "fps_floor": 60,
  "modifiers": ["motion_comfort"],
  "tags": ["streaming", "steam-link", "tv"],
  "description": "Optimised for 60 FPS 1080p streaming over Steam Link with flat frame cadence.",
  "files": [
    {
      "relative_path": "UserSettings.json",
      "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }
  ]
}
```

---

## Core Safety Rules

1. **Process verification before switching:** Always verify that the game process is **not running** before applying or switching configuration files. Games hold configurations in memory and will overwrite file changes upon exit.
2. **Pre-switch safety snapshot:** Always create a timestamped backup in `%LOCALAPPDATA%\ReFrame\Backups\<Game>_pre_switch_<timestamp>\` before switching profiles so any in-game modifications made since the last save are preserved.
3. **No file deletion:** Switching profiles overwrites configuration files with the target profile's version; it never deletes configuration directories or saves.
4. **Sanitise names:** Game names and profile names must be sanitised against filesystem reserved characters (`\ / : * ? " < > |`).
5. **Encoding and BOM preservation:** When mutating or generating configuration files (especially for Unreal Engine or legacy game engines), preserve the exact original file encoding and Byte Order Mark (BOM). In PowerShell 7+, `Set-Content -Encoding UTF8` writes UTF-8 _without_ BOM by default. For games requiring a BOM (where a missing BOM causes config parser crashes or startup failure), explicitly use `-Encoding utf8BOM` or `[System.Text.UTF8Encoding]::new($true)`.

---

## Core Workflows

### 1. Saving a Profile (`save profile <game> <name> [description]`)

Use this workflow to snapshot the current working configuration into a named profile:

#### Step 1 — Check process state

Verify the game is not currently running:

```powershell
$gameSafe = [WildcardPattern]::Escape($GameName)
$running = Get-Process | Where-Object { $_.ProcessName -like "*$gameSafe*" -or $_.MainWindowTitle -like "*$gameSafe*" }
if ($running) {
    Write-Warning "Game '$GameName' appears to be running ($($running.ProcessName)). Exit the game before saving configuration files to ensure current settings are written to disk."
}
```

#### Step 2 — Locate active config files

Use the game's known paths from `knowledge/games/<game>.json` or the config discovery search from [reframe.agent.md](../../agents/reframe.agent.md).

#### Step 3 — Gather profile context

Determine the current display resolution and refresh rate (from DxDiag or system scan), optimisation goal, and active modifiers:

```powershell
# Sanitise paths
$safeGame = $GameName -replace '[\\/:*?"<>|]', '_' -replace '\.\.', '_'
$safeProfile = $ProfileName -replace '[\\/:*?"<>| ]', '-'
$profileDir = "$env:LOCALAPPDATA\ReFrame\Profiles\$safeGame\$safeProfile"
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
```

#### Step 4 — Copy config files and compute hashes

```powershell
# Copy config files into profile directory
Copy-Item -Path $activeConfigPath -Destination $profileDir -Force

# Calculate file hash
$hash = (Get-FileHash -Path $activeConfigPath -Algorithm SHA256).Hash
```

#### Step 5 — Write `profile.json`

Write the metadata descriptor to `$profileDir\profile.json`.

#### Step 6 — Report confirmation

Present the saved profile details:

- Game name
- Profile name and storage path
- Target resolution and frame cap
- Captured files and SHA256 checksums

---

### 2. Switching Profiles (`switch config <game> <name>`)

Use this workflow to activate a previously saved profile:

#### Step 1 — Validate profile existence

Check if `$env:LOCALAPPDATA\ReFrame\Profiles\$safeGame\$safeProfile` exists. If not, list available profiles for the game.

#### Step 2 — Enforce process check

Run the process check. **Refuse to switch if the game is running:**

> **Cannot switch profile while [Game] is running.**
> Please exit the game first, then run `switch config [Game] [Profile]`. If configs are replaced while running, the game will overwrite them when closing.

#### Step 3 — Create pre-switch safety snapshot

Backup current active configuration files:

```powershell
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$snapshotDir = "$env:LOCALAPPDATA\ReFrame\Backups\${safeGame}_pre_switch_${timestamp}"
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null
Copy-Item -Path $activeConfigPath -Destination $snapshotDir -Force
```

#### Step 4 — Apply profile files

Copy stored configuration files from the profile directory to the game's active configuration path:

```powershell
Copy-Item -Path "$profileDir\*" -Destination $activeConfigDir -Exclude "profile.json" -Force
```

#### Step 5 — Report switch summary

Confirm the profile switch:

- Previous profile / pre-switch backup location
- Activated profile name and tags
- Key settings activated (Resolution, Frame Cap, Quality Preset, Low Latency Mode)

---

### 3. Listing Profiles (`list profiles [game]`)

List all saved profiles and indicate which one matches the active game configuration:

```powershell
$profileBase = "$env:LOCALAPPDATA\ReFrame\Profiles"
if ($GameName) {
    $searchDir = "$profileBase\$($GameName -replace '[\\/:*?"<>|]', '_')"
} else {
    $searchDir = $profileBase
}

Get-ChildItem -Path $searchDir -Filter "profile.json" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Get-Content $_.FullName | ConvertFrom-Json
}
```

#### Presentation format:

```markdown
## Saved Profiles: Cyberpunk 2077

| Profile          | Status       | Target Display    | Goal          | Modifiers      | Description                                           |
| ---------------- | ------------ | ----------------- | ------------- | -------------- | ----------------------------------------------------- |
| `desk-ultrawide` | **[ACTIVE]** | 5120×1440 @ 240Hz | Quality       | motion_comfort | Primary desk monitor; RT Ultra, DLSS Quality          |
| `steam-link-tv`  | Available    | 1920×1080 @ 60Hz  | Balanced (60) | motion_comfort | Living room TV streaming; flat 60 FPS cap, borderless |
| `competitive`    | Available    | 5120×1440 @ 240Hz | Performance   | none           | Low latency; Reflex Boost, minimal clutter, SSR off   |
```

Determine `[ACTIVE]` status by comparing SHA256 hashes of the active configuration files against each profile's stored hash.

---

### 4. Diffing Profiles (`diff profiles <game> <profile_a> <profile_b>`)

Compare the configuration keys between two saved profiles (or between a profile and the currently active configuration):

1. Read both configuration files into memory.
2. Parse key-value pairs according to file format (INI, JSON, CFG, etc.).
3. Present a side-by-side comparison of differences:

```markdown
## Profile Comparison: Cyberpunk 2077

**Profile A:** `desk-ultrawide`  
**Profile B:** `steam-link-tv`

| Key / Setting | `desk-ultrawide` | `steam-link-tv`        | Impact                                                |
| ------------- | ---------------- | ---------------------- | ----------------------------------------------------- |
| `Resolution`  | 5120×1440        | 1920×1080              | Matches TV client stream resolution                   |
| `WindowMode`  | Fullscreen       | Borderless             | Prevents capture freezes on stream                    |
| `MaxFPS`      | 0 (Uncapped)     | 60                     | Synchronises with 60Hz stream encoder                 |
| `RayTracing`  | On               | Off                    | Preserves 60 FPS frame time stability                 |
| `DLSS Preset` | Quality          | Quality (Native 1080p) | Crisp text and reduced stream compression artifacts   |
| `VSync`       | Off (G-Sync)     | Off                    | In-game VSync disabled to avoid double-buffer latency |
```

---

## Profile Context Guidelines

### Display Switching & Headroom Reallocation Rules

When moving between displays of differing resolutions:

| Transition                                            | Pixel Count Change     | ReFrame Adjustment Strategy                                                                                                                                                                                                                                                                       |
| ----------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **High Res → Low Res**<br>(e.g. 5120×1440/4K → 1080p) | **~65–75% reduction**  | **Reallocate GPU headroom:**<br>• Upgrade upscaler preset (e.g. DLSS/FSR _Performance_ → _Quality_ or native _DLAA_)<br>• Enable high-cost fidelity (Ray Tracing reflections, Ultra volumetric fog, High shadows)<br>• Re-centre or adjust HUD scale if moving from ultrawide (32:9/21:9) to 16:9 |
| **Low Res → High Res**<br>(e.g. 1080p → 4K/Ultrawide) | **~3× to 4× increase** | **Conserve GPU bandwidth & VRAM:**<br>• Switch upscaler to _Balanced_ or _Performance_<br>• Step down volumetric clouds/fog and screen-space reflections<br>• Verify VRAM headroom before enabling Ultra textures                                                                                 |

### Streaming & Remote Play Rules (Steam Link, Moonlight, Sunshine, Steam Deck)

1. **Resolution Matching:** Match client display natively (1920×1080 for standard TV/Steam Link; 1280×800 for Steam Deck). Avoid downsampling on the host unless supersampling is explicitly requested.
2. **Frame Rate Capping:** Set a rigid frame cap matching client refresh rate (usually 60 FPS flat or 120 FPS). Uncapped frame rates cause encoder queue stutter and packet jitter.
3. **In-Game VSync:** Recommend **Off** in-game. Presentation timing is handled by the streaming client. Double VSync adds perceptible input lag.
4. **Window Mode:** Prefer **Borderless Windowed** mode to prevent host black screens, capture freezes, or alt-tab desktop focus drops.
5. **Post-Processing Clarity:** Disable chromatic aberration, film grain, and heavy depth of field. These effects introduce high-frequency noise that confuses video compression algorithms (H.264/HEVC/AV1), causing severe blocky compression artifacts over network streams.

### Competitive Mode Rules

1. **Input Latency Minimisation:**
   - NVIDIA Reflex: `On + Boost`
   - AMD Anti-Lag: `Enabled`
   - Frame rate cap: Monitor refresh rate minus 3 FPS (if using G-Sync/FreeSync) or in-engine cap matching monitor Hz.
2. **Visual Clarity & De-cluttering:**
   - Motion Blur: **Off**
   - Depth of Field: **Off**
   - Lens Flare & Bloom: **Off**
   - Ambient Occlusion: **Off** or Low (removes distracting contact shadows)
   - Foliage / Grass Density: **Low** (prevents visual obstruction of targets)
3. **Selective Quality Preservation:**
   - Texture Quality: Keep **High** if VRAM allows (textures are memory-bound, not compute-bound, and improve character silhouette contrast).
   - Dynamic Shadows: Keep at **Medium** if the game renders competitive player shadows, so opponents around corners remain visible.

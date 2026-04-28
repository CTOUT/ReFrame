# Changelog

All notable changes to ReFrame will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- `knowledge/game-engines/source-2.json` — Source 2 engine profile (2.x): 6 video.txt keys + 3 console vars + 4 launch options; documents dual-surface config model (cs2_video.txt + autoexec.cfg); covers CS2 and Dota 2 detection; VAC-safety notes included
- `knowledge/games/counter-strike-2.json` — Counter-Strike 2 profile: Steam path; 5 video keys; 5 console vars including fps_max with match_monitor_hz_plus_ten token, cl_forcepreload, mat_queue_mode, instanced draw call limit; 4 launch options; NVIDIA Reflex and AMD Anti-Lag+ manual notes; CS:GO obsolescence warning
- `knowledge/game-engines/rage.json` — RAGE engine profile (5.x): 7 keys covering textures, shadows, reflections, AA, grass, shaders, and post-FX; fallback_for RAGE 6/7 (RDR2); documents settings.xml overwrite behaviour
- `knowledge/games/gta-v.json` — Grand Theft Auto V profile (aliases: GTA V, GTA 5): Steam, Epic, and Rockstar Launcher paths; 8 keys including MotionBlurStrength with motion_comfort modifier; 3 manual-only settings (population density/variety, extended distance); Enhanced Edition (2022) DLSS/FSR and ray tracing notes
- `knowledge/game-engines/redengine-4.json` — REDengine 4 engine profile (4.x): 3 keys covering texture streaming distance, NPC physics rig limit, and SSR quality; documents dual-location config model (UserSettings.json in Documents + engine override INIs in game install); notes that UserSettings.json is overwritten by the in-game menu
- `knowledge/games/cyberpunk-2077.json` — Cyberpunk 2077 profile: Steam, GOG, and Epic config paths; 5 engine override INI keys (streaming, rig limit, SSR, AO, volumetric fog); engine_overrides documenting UserSettings.json overwrite behaviour and SpawnSystem/crowd density deprecation in patch 2.0; 4 manual-only settings (upscaling, RT/path tracing, crowd density, FOV with motion_comfort modifier); DLSS DLL replacement note

### Fixed

- `system-scan` skill — DxDiag post-exit polling: added a stability loop after `WaitForExit` that waits until the XML file size is stable for two consecutive 500 ms checks before proceeding, preventing partial-read failures on slower systems
- `system-scan` skill — cache policy: `scan system` now reuses a valid post-boot cache instead of always regenerating; use `scan system --fresh` (or say "rescan", "re-scan", "fresh scan") to force a new DxDiag run
- `reframe.agent.md` — greeting updated to document `scan system --fresh`

### Added

- `knowledge/game-engines/unreal-engine-5.json` — Unreal Engine 5 engine profile (5.x): 17 keys covering TSR, Lumen GI, Lumen Reflections, Virtual Shadow Maps, scalability groups (sg.GlobalIlluminationQuality and sg.ReflectionQuality are new to UE5), texture streaming pool, VSync, and frame rate cap; documents Windows config path change from WindowsNoEditor (UE4) to Windows (UE5); 0-4 scalability range throughout; four sources
- `knowledge/games/skyrim-special-edition.json` — Skyrim Special Edition profile: Steam, GOG, and Xbox Game Pass config paths; 11 INI keys across Display, Imagespace, and Grass sections; engine override note (in-game menu overwrites INI); manual-only settings (resolution, AA / Skyrim Upscaler); notes covering SKSE64, ENB, Community Shaders, BethINI, and Anniversary Edition
- `knowledge/INDEX.json` — machine-readable index of all game and engine profiles; lists name, file, engine, platforms, key count, profile version, and last-updated date for each entry; updated with every new or changed profile
- `reframe.agent.md` — knowledge capture workflow: after analysing an unknown game, the agent offers to write `knowledge/games/<game>.json` from session findings and prompts the user to contribute via PR or issue form

### Changed

- All knowledge files (`games/*.json`, `game-engines/*.json`) — added `profile_version` (semver) and `updated` (ISO 8601 date) fields to support change tracking
- Both contributor templates (`knowledge/templates/`) — added `profile_version` and `updated` as required fields with authoring guidance
- `knowledge/templates/game-engine.template.json` — documented one-file-per-major-version convention in `_instructions` and `version_range` field guidance
- `CONTRIBUTING.md` — added engine versioning convention section: one file per major version, minor-version quirks go in Tier 1 `engine_overrides`, guidance on when to create vs extend
- `knowledge/game-engines/unreal-engine-4.json` — removed Unreal Engine 5 from `fallback_for` now that `unreal-engine-5.json` exists; bumped profile to 1.0.1
- `.github/ISSUE_TEMPLATE/knowledge_submission.yml` — Knowledge Submission issue form for non-git contributors; accepts generated or hand-authored JSON with verification checklist
- `CONTRIBUTING.md` — two-path contribution guide: PR workflow (existing) and no-git issue form path (new)
- `.github/ISSUE_TEMPLATE/config.yml` — added "Browse game knowledge" contact link

---

## [v1.1.0] — 2026-04-27

### Security

- `release.yml` — fixed script injection: `${{ github.ref_name }}` was interpolated directly into bash; now passed via env var and referenced as `$GITHUB_REF_NAME` (CWE-78 / OWASP A05)
- `release.yml` — pinned `actions/checkout` to commit SHA `de0fac2e` (v6.0.2) and `softprops/action-gh-release` to `b4309332` (v3.0.0) to prevent supply-chain compromise via mutable tags
- `release.yml` — added `fail_on_unmatched_files: true` to catch accidental release asset omissions
- `reframe.agent.md` — fixed backup path traversal: game name is now sanitised (strips `\/:*?"<>|` and `..`) before use in `$backupDir` path construction (OWASP A01)
- `reframe.agent.md` — fixed PowerShell wildcard injection: `$game` is now escaped with `[WildcardPattern]::Escape()` before use in `-like` file search patterns (OWASP A05)
- `install.ps1` — added explicit `..` check on `$Ref` parameter to prevent download redirection to arbitrary GitHub repository paths (OWASP A01)

### Added

- `knowledge/games/` — structured per-game config profiles (Tier 1); Elden Ring and Dead Island 2 added
- `knowledge/game-engines/` — structured per-engine default profiles (Tier 2); Unreal Engine 4 added
- `knowledge/templates/` — contributor templates (`game.template.json`, `game-engine.template.json`)
- Dead Island 2 entry in `docs/GAMES.md` including engine overrides table and FSR 2 crash bug documentation
- `CONTRIBUTING.md` — expanded knowledge base contribution guide with schema documentation, contributor templates, and engine file resolution rules
- `.vscode/extensions.json` — removed deprecated `GitHub.copilot` extension recommendation (superseded by `GitHub.copilot-chat`)

### Changed

- `README.md` — repo-level install (clone + `-Target repo`) is now the recommended path; user-level install demoted to "quick install" with explicit knowledge base caveat
- `install.ps1` — user-level install prints a note explaining that the knowledge base is unavailable and recommends the repo-level install for full coverage
- `docs/TROUBLESHOOTING.md` — new; covers agent not appearing, DxDiag failures, config not found, registry elevation, game config resets, knowledge base fallback, backup/rollback, and Steam Deck / Linux / macOS status
- `.github/ISSUE_TEMPLATE/bug_report.yml` and `feature_request.yml` — GitHub Issue Forms for structured bug reports and feature requests
- `.github/ISSUE_TEMPLATE/config.yml` — disables blank issues; routes security reports to private advisory
- `.github/pull_request_template.md` — PR checklist covering all change types

- Agent tier resolution updated: Tier 2 now resolves against `knowledge/game-engines/` JSON files before falling back to embedded engine defaults
- Engine file `fallback_for` field (renamed from `also_applies_to`) with documented resolution rules: exact-match wins unconditionally; fallback coverage used only when no exact file exists

---

## [v1.0.0] — 2026-04-27

### Added

- Initial release of the ReFrame game configuration optimisation agent
- `scan system` — hardware detection (CPU, GPU, RAM, storage, OS, power plan)
- `optimise <game>` — full optimisation workflow: discover configs, analyse, preview, apply
- `analyse config <path>` — analyse a specific config file
- `check registry` — assess Windows gaming registry settings (multimedia scheduler, HAGS, power plan, Game Mode)
- Registry optimisation: NetworkThrottlingIndex, SystemResponsiveness, GPU Priority, Win32PrioritySeparation, HAGS, Game Mode
- Hardware tier classification: high-end / mid-range / low-end
- GPU vendor detection and vendor-specific guidance: DLSS (NVIDIA), FSR (AMD), XeSS (Intel)
- Automatic backup to `%LOCALAPPDATA%\ReFrame\Backups\` before any modification
- Rollback workflow: list and restore backups
- Safety rules enforced: no silent changes, no deletions, always confirm before apply
- `install.ps1` installer for user-level and repo-level installation
- Docs: `REGISTRY.md` (Windows gaming registry reference), `GAMES.md` (known game config paths)

[Unreleased]: https://github.com/CTOUT/ReFrame/compare/v1.1.0...HEAD
[v1.1.0]: https://github.com/CTOUT/ReFrame/compare/v1.0.0...v1.1.0
[v1.0.0]: https://github.com/CTOUT/ReFrame/releases/tag/v1.0.0

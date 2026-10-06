# TODO

Tracked work items for ReFrame. Items are moved from here to `CHANGELOG.md` when completed.

---

## In Progress

_No active work items currently in progress._

---

## Planned

### Configuration & Profile Management

- [ ] **Backup Review** — review backup strategy and naming conventions for ReFrame. Create registry import files (`.reg`) and structured restore notes for changes and rollback.
- [ ] **Export report** — save optimisation report as a Markdown or HTML file.
- [ ] **Benchmark integration** — optionally run a quick GPU benchmark to calibrate tier classification.

### Engine & Config Parsers

- [ ] **Unreal Engine GVAS binary save parser** — add native support for parsing, extracting, and modifying Unreal Engine 4/5 `.sav` files (e.g. `GVAS` header format / `uesave` integration) for games that serialize graphics and upscaling settings into binary save containers rather than plain text `.ini` files.
- [ ] **Config format support: TOML** — add TOML parsing for modern game configs.
- [ ] **Config format support: Unreal Engine DefaultEngine.ini deep analysis** — key-by-key UE4/5 reference.

### GPU Driver & Vendor Integrations

- [ ] **NVIDIA Control Panel integration** — read/write NVCP settings (Low Latency Mode, Max Frame Rate, Texture Filtering) via NVAPI or registry.
- [ ] **AMD Adrenalin integration** — read and write AMD Software settings via the Adrenalin API or registry keys exposed by the driver.
- [ ] **Intel Arc Control integration** — read/write Intel Arc settings.

### Platform & Ecosystem

- [ ] **Non-Windows platform support** — Linux, macOS, and Steam Deck; requires shell-based hardware detection (replacing DxDiag / `Get-CimInstance`), platform-appropriate config path discovery, and removal of Windows-registry-specific workflows. Steam Deck (SteamOS / Proton) is the highest-priority target given its gaming focus. Tracked separately from `install.sh` (installer is a small part of this; the agent itself needs significant changes).
- [ ] **install.sh** — Bash installer for macOS / Linux (prerequisite: non-Windows platform support above).
- [ ] **GitHub Pages website** — public-facing project site hosted via `gh-pages` branch or `/docs` folder. Scope: landing page with project overview and install instructions, searchable/browsable game profiles (rendered from the `knowledge/` JSON), engine compatibility matrix, and links to GAMES.md and CONTRIBUTING.md. Consider a static site generator (Jekyll / Astro) or a hand-crafted single-page HTML that reads the knowledge JSON at build time.
- [ ] **Refactor** - migration to alternative non-Powershell solution?

---

## Completed

- [x] **Config Profiles & Switcher** — add named configuration profiles and profile-switching capabilities per game (`.github/skills/config-profiles/SKILL.md`). Supports rapid toggles between distinct operational contexts:
  - _Display Switching & Headroom Reallocation:_ switching between primary monitor (e.g. 5120×1440 or 4K) and secondary screens (1080p/1440p) where reduced resolution frees GPU headroom to unlock higher visual quality, ray tracing, or DLSS/FSR Quality/DLAA modes.
  - _Streaming & Remote Play:_ optimized targets for Steam Link, Moonlight/Sunshine, or Steam Deck streaming (target resolution, hard frame cap matching stream encoder cadence, borderless windowed presentation, disabled in-game VSync).
  - _Playstyle Presets:_ one-click switching between _Competitive Mode_ (low latency, Reflex/Anti-Lag, stripped visual clutter, maximum visibility) and _Cinematic Mode_ (maximum fidelity, ambient occlusion, ray tracing).
  - _Safety & Integrity:_ game process detection (prevent swapping while game is running), pre-switch safety snapshots, and profile diffing.
- [x] **External source references in knowledge profiles** — `sources` field migrated from a flat string array to a structured `{ url, type, label }` object array across all 24 game profiles and 14 engine profiles. Types: `wiki`, `fix_db` (WSGF), `official`, `community`, `editorial`. WSGF entries added to 8 titles with notable widescreen/ultrawide considerations (Elden Ring, Cyberpunk 2077, GTA V, Skyrim SE, Baldur's Gate 3, Dead Island 2, CS2, PUBG). Both profile templates updated to document the new schema.
- [x] **Game-specific knowledge base (v1.2.0)** — all 19 queued game profiles completed: 26 games total, 14 engine profiles; covers UE4/UE5, Source 2, REDengine 4, RAGE, Blizzard WoW Engine, Unity, Divinity Engine 4.0, IW Engine 9, Riot Engine, Keen Engine, Source (Modified), Evolution Engine, and Minecraft Java Engine.
- [x] `.github/ISSUE_TEMPLATE/` — bug report and feature request templates (GitHub Issue Forms)
- [x] `.github/pull_request_template.md` — PR checklist mirroring CONTRIBUTING.md
- [x] `docs/TROUBLESHOOTING.md` — common failure scenarios with fixes
- [x] Install hierarchy updated — repo-level install promoted as recommended path; user-level install documents knowledge base caveat
- [x] Initial agent definition (`reframe.agent.md`) — v1.0.0
- [x] System scan workflow — v1.0.0
- [x] Config file discovery and analysis — v1.0.0
- [x] Registry analysis and optimisation — v1.0.0
- [x] Hardware tier classification — v1.0.0
- [x] GPU vendor detection (NVIDIA / AMD / Intel) — v1.0.0
- [x] Backup and rollback workflow — v1.0.0
- [x] `install.ps1` installer — v1.0.0
- [x] `REGISTRY.md` reference — v1.0.0
- [x] `GAMES.md` known paths reference — v1.0.0

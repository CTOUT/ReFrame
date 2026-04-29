# TODO

Tracked work items for ReFrame. Items are moved from here to `CHANGELOG.md` when completed.

---

## In Progress

- [x] **Game-specific knowledge base** — all 19 queued game profiles completed: 22 games total, 14 engine profiles; covers UE4/UE5, Source 2, REDengine 4, RAGE, Blizzard WoW Engine, Unity, Divinity Engine 4.0, IW Engine 9, Riot Engine, Keen Engine, Source (Modified), Evolution Engine, and Minecraft Java Engine.

### Knowledge Base Queue

Completed items are struck through. Each item requires an engine profile (if new) + a game profile.

| # | Game | Engine | Engine profile | Status |
|---|---|---|---|---|
| 1 | Cyberpunk 2077 | REDengine 4 | ✅ `redengine-4.json` | ✅ Done |
| 2 | GTA V | RAGE | ✅ `rage.json` | ✅ Done |
| 3 | Counter-Strike 2 | Source 2 | ✅ `source-2.json` | ✅ Done |
| 4 | World of Warcraft | Blizzard WoW engine | ✅ `blizzard-wow-engine.json` | ✅ Done |
| 5 | PUBG: Battlegrounds | UE4 | ✅ Done | ✅ Done |
| 6 | Valorant | UE4 | ✅ Done | ✅ Done |
| 7 | Fortnite | UE5 | ✅ Done | ✅ Done |
| 8 | Marvel Rivals | UE5 | ✅ Done | ✅ Done |
| 9 | Windrose | UE5 (suspected) | ✅ Done | ✅ Done |
| 10 | Valheim | Unity | ✅ `unity.json` | ✅ Done |
| 11 | Rust | Unity | ✅ (reuses #10) | ✅ Done |
| 12 | Dota 2 | Source 2 | ✅ (reuses #3) | ✅ Done |
| 13 | Baldur's Gate 3 | Divinity 4.0 | ✅ `divinity-engine-4.json` | ✅ Done |
| 14 | Call of Duty: BO6 | IW Engine 9 | ✅ `iw-engine-9.json` | ✅ Done |
| 15 | League of Legends | Riot custom engine | ✅ `riot-engine.json` | ✅ Done |
| 16 | Enshrouded | Keen proprietary | ✅ `keen-engine.json` | ✅ Done |
| 17 | Apex Legends | Modified Source | ✅ `source-modified.json` | ✅ Done |
| 18 | Warframe | Evolution Engine | ✅ `evolution-engine.json` | ✅ Done |
| 19 | Minecraft | Minecraft Java Engine | ✅ `minecraft-java-engine.json` | ✅ Done |

## Planned

- [ ] **Non-Windows platform support** — Linux, macOS, and Steam Deck; requires shell-based hardware detection (replacing DxDiag / `Get-CimInstance`), platform-appropriate config path discovery, and removal of Windows-registry-specific workflows. Steam Deck (SteamOS / Proton) is the highest-priority target given its gaming focus. Tracked separately from `install.sh` (installer is a small part of this; the agent itself needs significant changes).
- [ ] **AMD Adrenalin integration** — read and write AMD Software settings via the Adrenalin API or registry keys exposed by the driver
- [ ] **NVIDIA Control Panel integration** — read/write NVCP settings (Low Latency Mode, Max Frame Rate, Texture Filtering) via NVAPI or registry
- [ ] **Intel Arc Control integration** — read/write Intel Arc settings
- [ ] **install.sh** — Bash installer for macOS / Linux (prerequisite: non-Windows platform support above)
- [ ] **Config format support: TOML** — add TOML parsing for modern game configs
- [ ] **Config format support: Unreal Engine DefaultEngine.ini deep analysis** — key-by-key UE4/5 reference
- [ ] **Benchmark integration** — optionally run a quick GPU benchmark to calibrate tier classification
- [ ] **Export report** — save optimisation report as a Markdown or HTML file
- [x] **External source references in knowledge profiles** — `sources` field migrated from a flat string array to a structured `{ url, type, label }` object array across all 24 game profiles and 14 engine profiles. Types: `wiki`, `fix_db` (WSGF), `official`, `community`, `editorial`. WSGF entries added to 8 titles with notable widescreen/ultrawide considerations (Elden Ring, Cyberpunk 2077, GTA V, Skyrim SE, Baldur's Gate 3, Dead Island 2, CS2, PUBG). Both profile templates updated to document the new schema.
- [ ] **Backup Review** — Review backup strategy and naming conventions for ReFrame. Create registry import files for changes and rollback.

## Completed

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

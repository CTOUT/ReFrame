# TODO

Tracked work items for ReFrame. Items are moved from here to `CHANGELOG.md` when completed.

---

## In Progress

- [ ] **Game-specific knowledge base** — `knowledge/games/` and `knowledge/game-engines/` structure created; Elden Ring, Dead Island 2, and Unreal Engine 4 profiles added. Remaining: Cyberpunk 2077, CS2, Fortnite, Minecraft, Fallout 4 and other popular titles.

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

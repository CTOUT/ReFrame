# TODO

Tracked work items for ReFrame. Items are moved from here to `CHANGELOG.md` when completed.

---

## In Progress

_(none)_

## Planned

- [ ] **AMD Adrenalin integration** — read and write AMD Software settings via the Adrenalin API or registry keys exposed by the driver
- [ ] **NVIDIA Control Panel integration** — read/write NVCP settings (Low Latency Mode, Max Frame Rate, Texture Filtering) via NVAPI or registry
- [ ] **Intel Arc Control integration** — read/write Intel Arc settings
- [ ] **Game-specific knowledge base** — expand `knowledge/games/` with profiles for popular titles (Elden Ring, Cyberpunk 2077, CS2, Fortnite, etc.)
- [ ] **install.sh** — Bash installer for macOS / Linux (future-proofing for when Copilot agent support extends beyond Windows)
- [ ] **Config format support: TOML** — add TOML parsing for modern game configs
- [ ] **Config format support: Unreal Engine DefaultEngine.ini deep analysis** — key-by-key UE4/5 reference
- [ ] **Benchmark integration** — optionally run a quick GPU benchmark to calibrate tier classification
- [ ] **Export report** — save optimisation report as a Markdown or HTML file

## Completed

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

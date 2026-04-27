# Changelog

All notable changes to ReFrame will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

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

[Unreleased]: https://github.com/CTOUT/ReFrame/compare/v1.0.0...HEAD
[v1.0.0]: https://github.com/CTOUT/ReFrame/releases/tag/v1.0.0

# Changelog

All notable changes to ReFrame will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

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

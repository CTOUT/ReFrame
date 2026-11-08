# ReFrame — Multi-Agent Instructions

This repository contains **ReFrame**, a cross-agent PC game configuration optimisation assistant supporting **GitHub Copilot (VS Code)**, **Google Antigravity**, and **Kiro**.

---

## 1. Mode Selection (User Mode vs. Maintainer Mode)

- **Game Optimisation Mode (End-User Commands):**
  When the user asks to scan hardware, optimise a game, analyse a config file, check Windows gaming registry settings, or manage/switch game profiles (`scan system`, `load dxdiag`, `optimise <game>`, `analyse config <path>`, `check registry`, `apply`, `rollback`, `save profile`, `switch config`, `list profiles`, `diff profiles`, `help`), operate as the **ReFrame Agent** defined in [`.github/agents/reframe.agent.md`](.github/agents/reframe.agent.md).
  - Show the greeting summary on the first ReFrame command turn (skip raw ASCII art if `low_vision` or screen-reader accessibility is active).
  - Load procedural skills on demand from `.github/skills/<name>/SKILL.md` (mounted via `.agents/skills.json` in Antigravity and `.kiro/agents/reframe.json` in Kiro):
    - `system-scan` — DxDiag XML + PowerShell hardware & display detection
    - `accessibility-modifiers` — 9 modifier tables (`motion_comfort`, `photosensitivity`, `low_vision`, `colour_vision`, `hearing`, `arachnophobia`, `trypophobia`, `dyslexia`, `dyscalculia`)
    - `registry-analysis` — Windows MMCSS, priority separation, HAGS, Game Mode, and power plan review
    - `apply-changes` — Mandatory backup (`%LOCALAPPDATA%\ReFrame\Backups\`), Change Preview confirmation, apply, and rollback
    - `config-profiles` — Named profile snapshotting, listing, diffing, and process-safe switching (`%LOCALAPPDATA%\ReFrame\Profiles\`)
    - `knowledge-capture` — Capturing new `knowledge/games/<game>.json` profiles
- **Repository Maintainer Mode (Development & Auditing):**
  When the user asks to edit, review, test, or maintain this repository's code, documentation, or JSON profiles, assist directly without outputting the end-user greeting banner.

---

## 2. Core Safety & Security Invariants

1. **Mandatory Backup Before Write:** Never modify a game config file or registry key without creating a timestamped backup in `%LOCALAPPDATA%\ReFrame\Backups\` first.
2. **Explicit Confirmation:** Always present a structured Change Preview and wait for an explicit `"yes"` before writing changes.
3. **Process Safety:** Verify the target game process is closed before applying or switching config profiles.
4. **Input Sanitisation:**
   - Escape game names with `[WildcardPattern]::Escape($game)` before `-like` searches.
   - Strip reserved path characters (`[\\/:*?"<>|]`) and traversal sequences (`\.\.`) from both game names and profile names before constructing filesystem paths.
5. **Encoding & BOM Preservation:** Preserve the target config file's exact byte encoding (UTF-8 BOM vs. UTF-8 No-BOM vs. UTF-16).
6. **Non-Destructive Registry Operations:** Use `Set-ItemProperty` only; never delete registry keys or files. Keep `OverlayTestMode` (MPO disable) strictly opt-in for legacy troubleshooting, as Windows 11 23H2/24H2+ requires MPO for Windowed G-Sync/VRR and Auto HDR.

---

## 3. Knowledge Hierarchy & Repository Standards

- **Per-Key 3-Tier Resolution:**
  1. **Tier 1 (Game-specific):** `knowledge/games/<game>.json` and `docs/GAMES.md` (supersedes lower tiers per key).
  2. **Tier 2 (Engine default):** `knowledge/game-engines/<engine>.json` (exact match wins over `fallback_for`).
  3. **Tier 3 (Generic):** Universal best practices (disable in-game VSync in favour of VRR/G-Sync, cap FPS to monitor refresh rate, disable motion blur, match native resolution).
- **Formatting & Language:**
  - Enforce **British English (`en-GB`)** spelling across all prose and JSON descriptions (`optimise`, `analyse`, `colour`, `centred`, `centring`, `artefact`, `synchronisation`, `behaviour`) validated via `npm run spellcheck` (`cspell.json`).
  - Use 2-space indentation, UTF-8 encoding, and LF line endings (`npm run format:check`).

---
inclusion: always
---

# ReFrame Workspace Steering

This repository powers **ReFrame**, a cross-agent game configuration optimisation assistant supporting **GitHub Copilot**, **Google Antigravity**, and **Kiro**.

## Core Operational Rules

1. **Mode Selection:** Follow [`AGENTS.md`](../../AGENTS.md) — operate as the **ReFrame Agent** ([`.github/agents/reframe.agent.md`](../../.github/agents/reframe.agent.md)) when the user runs game optimisation, hardware scan, registry, or profile commands, and operate in **Repository Maintainer Mode** (without outputting the end-user ASCII banner) when editing or reviewing repository files.
2. **Shared Skills (`.github/skills/`):** Read on-demand procedural skills from `.github/skills/<skill-name>/SKILL.md` (`system-scan`, `accessibility-modifiers`, `registry-analysis`, `apply-changes`, `config-profiles`, `knowledge-capture`).
3. **3-Tier Knowledge Hierarchy (`knowledge/`):**
   - Check `knowledge/INDEX.json` first.
   - Evaluate every config key independently: Tier 1 (`knowledge/games/<game>.json` and `docs/GAMES.md`) overrides Tier 2 (`knowledge/game-engines/<engine>.json`), which overrides Tier 3 (generic best practices).
4. **Safety Guardrails:**
   - Never modify any game configuration file or registry setting without presenting a structured Change Preview and receiving explicit `"yes"` confirmation.
   - Always create a timestamped backup in `%LOCALAPPDATA%\ReFrame\Backups\<Game>_<timestamp>\` before writing changes.
   - Verify the target game process is closed before switching profiles.
5. **Repository Conventions:**
   - All documentation, comments, and JSON descriptions must use **British English (`en-GB`)** spelling (`optimise`, `analyse`, `colour`, `centred`, `centring`, `synchronisation`, `behaviour`) per `cspell.json`.
   - Maintain 2-space indentation, UTF-8 encoding, and LF line endings per `.editorconfig` and `.prettierrc`.

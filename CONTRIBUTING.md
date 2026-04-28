# Contributing to ReFrame

Thanks for your interest in contributing. This document covers the development workflow and pre-commit checklist.

A [pull request template](../.github/pull_request_template.md) is pre-filled when you open a PR on GitHub — it mirrors the checklist below.

---

## Pre-commit Checklist

### Agent changes (`reframe.agent.md`)

- [ ] Instructions are clear, unambiguous, and internally consistent
- [ ] New tools added to the frontmatter only if actually used in the instructions
- [ ] Safety rules section still enforces: backup-before-write, confirm-before-apply, no deletions
- [ ] Accessibility modifier coverage is intact: `motion_comfort`, `photosensitivity`, `low_vision`, `colour_vision`, `arachnophobia`, `trypophobia`, `dyslexia`, `dyscalculia`
- [ ] PowerShell snippets tested on Windows 10/11
- [ ] No hardcoded user paths — use environment variables (`$env:USERPROFILE`, `$env:APPDATA`, etc.)
- [ ] `CHANGELOG.md` updated under `[Unreleased] → Added / Changed / Fixed`
- [ ] `README.md` updated if user-facing behaviour or commands change

### Knowledge base changes (`knowledge/games/`, `docs/`)

- [ ] File created from `knowledge/templates/game.template.json` or `knowledge/templates/game-engine.template.json`
- [ ] All `_instructions` and `_comment` fields removed before submitting
- [ ] Game config paths verified against a real installation
- [ ] Recommended values cited with source (benchmark, developer documentation, community guide)
- [ ] No values that could cause game instability flagged as safe without caveat
- [ ] Corresponding entry added or updated in `docs/GAMES.md`
- [ ] If the game has accessibility options (photosensitivity mode, colour blind mode, etc.), they are documented as **Manual** steps in `docs/GAMES.md`

### Installer changes (`install.ps1`)

- [ ] `-TimeoutSec 30` on all `Invoke-RestMethod` / `Invoke-WebRequest` calls
- [ ] Tested with `-DryRun` before a real install
- [ ] `CHANGELOG.md` updated

### Repository / docs changes

- [ ] `README.md` Repository Structure section reflects any new/removed files
- [ ] `CHANGELOG.md` updated
- [ ] `TODO.md` updated if a tracked item is completed or a new one is added

---

## Changelog Format

Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Add entries under `## [Unreleased]`.

```markdown
## [Unreleased]

### Added

- Short description of new feature

### Changed

- Short description of change to existing behaviour

### Fixed

- Short description of bug fix
```

---

## Cutting a Release

1. Ensure `CHANGELOG.md` `[Unreleased]` section is complete
2. Rename `[Unreleased]` to `[vX.Y.Z] — YYYY-MM-DD`
3. Add a new empty `[Unreleased]` section above it
4. Update the diff links at the bottom of `CHANGELOG.md`
5. Commit: `chore: prepare release vX.Y.Z`
6. Tag: `git tag vX.Y.Z -m "<release notes>"`
7. Push: `git push && git push --tags`

The release workflow will package `reframe-agent.zip` and publish it automatically.

---

## Adding Game Knowledge

### Two ways to contribute

| Path | When to use |
| ---- | ----------- |
| **Pull request** | You're comfortable with Git. Fork the repo, add or edit a JSON file, open a PR. The PR template will guide you through the checklist. |
| **Issue form** | No Git experience needed. Run ReFrame — if it analyses an unknown game it will offer to generate the JSON file for you. Copy the output and paste it into the [Knowledge Submission issue form](https://github.com/CTOUT/ReFrame/issues/new?template=knowledge_submission.yml). A maintainer will review and merge it. |

### Knowledge file locations

Game and engine knowledge lives in two places:

| Path                                        | Purpose                                                     |
| ------------------------------------------- | ----------------------------------------------------------- |
| `knowledge/games/<game-name>.json`          | Per-game config profile (Tier 1 — game-specific)            |
| `knowledge/game-engines/<engine-name>.json` | Per-engine default profile (Tier 2 — engine defaults)       |
| `docs/GAMES.md`                             | Human-readable reference — keep in sync with the JSON files |

### Adding a game (`knowledge/games/`)

Copy `knowledge/templates/game.template.json` to `knowledge/games/<kebab-case-game-name>.json` and fill it in. The template documents every field inline. Remove all `_instructions` and `_comment` fields before submitting.

Include:

- `game` — exact display name
- `engine` — underlying engine name (must match the `engine` field in the corresponding engine file, or `"unknown"`)
- `platforms` — one entry per store/platform, with `config_files` listing each file's path and format. Use environment variable placeholders: `%USERPROFILE%`, `%APPDATA%`, `%LOCALAPPDATA%`, `%PROGRAMFILES%`, `%PROGRAMFILES(X86)%`.
- `keys` — one entry per config key: `key`, `effect`, `recommendations` (with `performance` / `balanced` / `quality` values), and optional `notes`
- `engine_overrides` — **the most important section for games built on shared engines.** List any key where this game's behaviour differs from the engine default, with an explicit explanation of why (e.g. reset on launch, custom scaler, deliberate rebalance by the developer). Without this, ReFrame may apply an engine default that is wrong or harmful for this specific game.
- `notes` — version-specific caveats, known bugs, or other considerations
- `sources` — benchmark article, developer post, or community guide URL for each recommendation

Also add the game to `docs/GAMES.md` following the template at the top of that file, and keep both in sync.

### Adding an engine (`knowledge/game-engines/`)

Copy `knowledge/templates/game-engine.template.json` to `knowledge/game-engines/<kebab-case-engine-name>.json` and fill it in. The template documents every field inline. Remove all `_instructions` and `_comment` fields before submitting.

Include:

- `engine` and `version_range` — display name and version string (e.g. `"4.x"`)
- `fallback_for` — an array of engine names this file covers as a fallback **when no dedicated file exists** for those engines. See resolution rules below.
- `detection_signatures` — file names, section headers, and key prefixes the agent uses to identify this engine
- `config_file_locations` — Windows path template using `%LOCALAPPDATA%` etc.
- `keys` — one entry per key: `key`, `section`, `file`, `effect`, `recommendations` (per goal), optional `notes`
- `sources`

### Engine file resolution rules

The agent resolves Tier 2 (engine defaults) using these rules, evaluated in order:

1. **Exact match wins unconditionally.** If a file exists whose `engine` field matches the detected engine, use it. `fallback_for` on other files is ignored.
2. **Fallback coverage.** If no exact match exists, find files whose `fallback_for` array includes the detected engine. If more than one file qualifies, the file with the closest version match (highest version number that is still ≤ the detected version) takes priority.
3. **No match.** If neither rule yields a file, fall through to Tier 3 (generic best-practice rules).

**Example:** A UE5 game is detected. `unreal-engine-5.json` does not yet exist. `unreal-engine-4.json` has `"fallback_for": ["Unreal Engine 5"]` — so its defaults are used for any key not covered by a game-specific (Tier 1) entry. Once `unreal-engine-5.json` is created, it immediately takes over for all UE5 games regardless of `fallback_for`.

### Engine versioning convention

**One file per major engine version only.** Never create separate files for minor versions.

| Do | Don't |
| -- | ----- |
| `unreal-engine-4.json` covering `4.x` | `unreal-engine-4.27.json` |
| `unreal-engine-5.json` covering `5.x` | `unreal-engine-5.3.json` |

The rationale: engine files contain defaults that are **widely applicable** across all games on that engine. Minor-version differences — keys added in 4.27, deprecated in 5.1, or behaving differently for a specific title — are by definition game-specific. They belong in the Tier 1 game file's `engine_overrides` section, not in a split engine file.

**When to create a new engine file:** only when a new *major* version introduces a meaningfully different set of defaults (e.g. Lumen replacing SSGI in UE5, a new renderer architecture). If the defaults are largely the same, extend `fallback_for` on the existing file instead.

**When to edit an existing engine file:** when a default value changes across most games built on that major version, or when a new key becomes widely applicable. Increment `profile_version` (minor for new/changed keys, patch for corrections) and update `updated`.

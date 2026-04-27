# Contributing to ReFrame

Thanks for your interest in contributing. This document covers the development workflow and pre-commit checklist.

---

## Pre-commit Checklist

### Agent changes (`reframe.agent.md`)

- [ ] Instructions are clear, unambiguous, and internally consistent
- [ ] New tools added to the frontmatter only if actually used in the instructions
- [ ] Safety rules section still enforces: backup-before-write, confirm-before-apply, no deletions
- [ ] PowerShell snippets tested on Windows 10/11
- [ ] No hardcoded user paths — use environment variables (`$env:USERPROFILE`, `$env:APPDATA`, etc.)
- [ ] `CHANGELOG.md` updated under `[Unreleased] → Added / Changed / Fixed`
- [ ] `README.md` updated if user-facing behaviour or commands change

### Knowledge base changes (`knowledge/games/`, `docs/`)

- [ ] Game config paths verified against current game version
- [ ] Recommended values cited with source (benchmark, developer documentation, community guide)
- [ ] No values that could cause game instability flagged as safe without caveat

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

To add a new game's configuration profile, create a Markdown file in `knowledge/games/`:

```
knowledge/games/<GameName>.md
```

Include:
- Common config file paths (use environment variable placeholders)
- Key names and their effect on performance
- Recommended values per hardware tier
- Source citations (benchmark article, developer post, etc.)

See existing files in `knowledge/games/` for the expected structure.

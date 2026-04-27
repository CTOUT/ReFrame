# Pull Request

## Summary

<!-- One or two sentences describing what this PR does and why. -->

## Type of change

- [ ] Bug fix
- [ ] New game knowledge profile
- [ ] New engine knowledge profile
- [ ] Agent behaviour change
- [ ] Installer change
- [ ] Documentation / repo housekeeping

---

## Pre-merge checklist

<!-- Tick every item that applies to your change. Delete sections that don't apply. -->

### Agent changes (`reframe.agent.md`)

- [ ] Instructions are clear, unambiguous, and internally consistent
- [ ] New tools added to frontmatter only if actually used
- [ ] Safety rules still enforced: backup-before-write, confirm-before-apply, no deletions
- [ ] Accessibility modifier coverage intact: `motion_comfort`, `photosensitivity`, `low_vision`, `colour_vision`, `arachnophobia`, `trypophobia`, `dyslexia`, `dyscalculia`
- [ ] PowerShell snippets tested on Windows 10/11
- [ ] No hardcoded user paths — environment variables used throughout
- [ ] `CHANGELOG.md` updated
- [ ] `README.md` updated if user-facing behaviour or commands changed

### Knowledge base changes (`knowledge/`)

- [ ] File created from the appropriate template in `knowledge/templates/`
- [ ] All `_instructions` and `_comment` fields removed
- [ ] Config paths verified against a real installation
- [ ] Every recommended value has a source citation in the `sources` array
- [ ] No values that could cause game instability are flagged as safe without a caveat
- [ ] Corresponding entry added or updated in `docs/GAMES.md`
- [ ] Game accessibility options (photosensitivity mode, colour blind mode, etc.) documented as **Manual** steps in `docs/GAMES.md`

### Installer changes (`install.ps1`)

- [ ] `-TimeoutSec 30` on all `Invoke-RestMethod` / `Invoke-WebRequest` calls
- [ ] Tested with `-DryRun` before a real install
- [ ] `CHANGELOG.md` updated

### Repository / docs changes

- [ ] `README.md` Repository Structure section updated if files were added or removed
- [ ] `CHANGELOG.md` updated
- [ ] `TODO.md` updated if a tracked item is completed or a new one added

# ReFrame

A **GitHub Copilot agent** for game configuration optimisation. ReFrame detects your system hardware, locates game configuration files, analyses registry settings, and recommends or applies hardware-appropriate performance improvements — with automatic backup and rollback.

---

## What ReFrame Does

- **System detection** — reads CPU, GPU, RAM, storage type, and OS to build a hardware profile
- **Config file analysis** — finds and parses INI, CFG, XML, JSON, and other config formats across common game installation paths
- **Registry analysis** — checks Windows multimedia, scheduler, and GPU settings that affect gaming performance
- **Hardware-appropriate recommendations** — tailors suggestions to your hardware tier (high-end / mid-range / low-end)
- **GPU vendor guidance** — recommends DLSS (NVIDIA), FSR (AMD), or XeSS (Intel) where applicable
- **Safe application** — every change is previewed, confirmed, and backed up before writing
- **Rollback** — restore any previous config or registry state from the backup archive

> **Future:** Direct integration with AMD Adrenalin, NVIDIA Control Panel, and Intel Arc Control settings is planned but not yet available.

---

## Installation

### User-level install (recommended)

Places the agent in your VS Code user prompts folder. Works in every workspace immediately.

```powershell
# PowerShell (Windows)
irm https://raw.githubusercontent.com/CTOUT/ReFrame/main/install.ps1 | iex
```

For a verified install, pin to a release tag:

```powershell
.\install.ps1 -Ref v1.0.0
```

### Repo-level install

```powershell
.\install.ps1 -Target repo
```

This places the agent in `.github/agents/` and commits with the project, making it available to everyone on the team.

### Manual install

Download `reframe-agent.zip` from the [latest release](https://github.com/CTOUT/ReFrame/releases/latest) and extract to:

| Platform | User-level path                                    |
| -------- | -------------------------------------------------- |
| Windows  | `%APPDATA%\Code\User\prompts\`                     |
| macOS    | `~/Library/Application Support/Code/User/prompts/` |
| Linux    | `~/.config/Code/User/prompts/`                     |

Then restart VS Code (or `Developer: Reload Window`).

---

## Usage

Open Copilot Chat and select **ReFrame** from the agent picker, or type `@ReFrame`.

### Quick start

```
scan system
```

Detects your hardware and shows a system profile.

```
optimise Elden Ring
```

Finds config files for the named game, analyses current settings, and recommends improvements for your hardware.

```
check registry
```

Assesses Windows gaming registry settings (multimedia scheduler, GPU scheduling, power plan, etc.) and shows what to change.

### All commands

| Command                 | Description                                           |
| ----------------------- | ----------------------------------------------------- |
| `scan system`           | Detect hardware profile                               |
| `optimise <game>`       | Full optimisation workflow for the named game         |
| `analyse config <path>` | Analyse a specific config file                        |
| `check registry`        | Assess Windows gaming registry settings               |
| `apply`                 | Apply the pending change preview (after confirmation) |
| `rollback <game>`       | Restore a backup for the named game                   |
| `rollback last`         | Restore the most recent backup                        |
| `list backups`          | Show all ReFrame backups                              |
| `help`                  | Show command reference                                |

---

## How Changes Are Applied

ReFrame never modifies files or registry keys silently. Every session that results in changes follows this flow:

1. **Scan** — detect hardware and locate config files
2. **Analyse** — parse configs and registry, flag suboptimal settings
3. **Preview** — present a structured Change Preview showing old → new values and backup location
4. **Confirm** — user must type **yes** to proceed
5. **Backup** — original files are copied to `%LOCALAPPDATA%\ReFrame\Backups\<Game>_<timestamp>\`
6. **Apply** — changes are written
7. **Report** — each change is confirmed in the output

Registry changes that require Administrator are shown as runnable PowerShell commands if the session does not have elevation.

---

## Safety Notes

- ReFrame **never deletes files** — it only modifies or backs up
- Registry changes use `Set-ItemProperty` only — no key deletions
- A system restart is required for some registry changes (HAGS, priority separation)
- Config file backups are stored locally in `%LOCALAPPDATA%\ReFrame\Backups\`

---

## Repository Structure

```
ReFrame/
├── .github/
│   ├── agents/
│   │   └── reframe.agent.md        ← the agent definition
│   ├── workflows/
│   │   └── release.yml             ← GitHub Actions release workflow
│   └── CODEOWNERS
├── .vscode/
│   └── extensions.json
├── docs/
│   ├── REGISTRY.md                 ← Windows registry keys reference
│   └── GAMES.md                    ← Known game config paths and keys
├── knowledge/
│   └── games/                      ← Per-game optimisation knowledge
├── .gitattributes
├── .gitignore
├── .markdownlint.json
├── CHANGELOG.md
├── CONTRIBUTING.md
├── install.ps1
├── LICENSE
├── README.md
├── SECURITY.md
└── TODO.md
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities and installer verification guidance.

## License

[MIT](LICENSE)

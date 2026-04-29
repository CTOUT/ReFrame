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

### Recommended: clone and repo-level install

This gives you the full knowledge base (game-specific profiles, per-engine defaults) and keeps it up to date via `git pull`.

```powershell
git clone https://github.com/CTOUT/ReFrame.git
cd ReFrame
.\install.ps1 -Target repo
```

Open the `ReFrame` folder in VS Code. The agent is available as `@ReFrame` in that workspace and can read the `knowledge/` files at runtime.

> To pin to a specific release: `.\install.ps1 -Target repo -Ref v1.0.0`

### Quick install (any workspace, no clone needed)

Installs the agent to your VS Code user prompts folder so `@ReFrame` is available in every workspace without cloning.

```powershell
# PowerShell (Windows)
irm https://raw.githubusercontent.com/CTOUT/ReFrame/main/install.ps1 | iex
```

> **Note:** User-level installs do not include the `knowledge/` files. Game-specific profiles (Tier 1) and per-engine JSON defaults (Tier 2) are unavailable — the agent falls back to its embedded engine defaults and web lookups. For full knowledge base coverage, use the repo-level install above.

### Manual install

Download `reframe-agent.zip` from the [latest release](https://github.com/CTOUT/ReFrame/releases/latest) and extract to:

| Platform | User-level path                                    |
| -------- | -------------------------------------------------- |
| Windows  | `%APPDATA%\Code\User\prompts\`                     |
| macOS    | `~/Library/Application Support/Code/User/prompts/` |
| Linux    | `~/.config/Code/User/prompts/`                     |

Then restart VS Code (or `Developer: Reload Window`).

The same knowledge base caveat applies — for game-specific profiles, use the repo-level install.

---

## Usage

Open Copilot Chat and select **ReFrame** from the agent picker, or type `@ReFrame`.

### Quick start

```text
scan system
```

Detects your hardware and shows a system profile.

```text
optimise Elden Ring
```

Finds config files for the named game, analyses current settings, and recommends improvements for your hardware.

```text
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

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for help with common issues.

---

## Repository Structure

```text
ReFrame/
├── .github/
│   ├── agents/
│   │   └── reframe.agent.md        ← the agent definition
│   ├── skills/
│   │   └── system-scan/            ← hardware detection skill
│   ├── workflows/
│   │   └── release.yml             ← GitHub Actions release workflow
│   └── CODEOWNERS
├── .vscode/
│   └── extensions.json
├── docs/
│   ├── GAMES.md                    ← Human-readable game config reference
│   ├── REGISTRY.md                 ← Windows registry keys reference
│   └── TROUBLESHOOTING.md          ← Common problems and fixes
├── knowledge/
│   ├── game-engines/               ← Per-engine default profiles (Tier 2)
│   ├── games/                      ← Per-game config profiles (Tier 1)
│   └── templates/                  ← Templates for contributors
├── .gitattributes
├── .gitignore
├── .markdownlint.json
├── CHANGELOG.md
├── CITATION.cff
├── CONTRIBUTING.md
├── install.ps1
├── LICENSE
├── llms.txt                    ← AI crawler guidance
├── README.md
├── SECURITY.md
└── TODO.md
```

---

## FAQ

**Does ReFrame work with any game?**
ReFrame works with any game that stores configuration in INI, CFG, XML, or JSON files. It ships with a knowledge base of **22 game profiles** (Cyberpunk 2077, World of Warcraft, Counter-Strike 2, Apex Legends, Minecraft, Baldur's Gate 3, and more) across **14 engine profiles** (UE4/UE5, Source 2, REDengine 4, Unity, and more). Use `optimise <game name>` and ReFrame will locate and analyse whatever configs it finds — even for titles without a dedicated profile.

**Will ReFrame break my game or corrupt my save files?**
No. ReFrame only modifies game configuration files and Windows registry settings — never save data. Every change is backed up to `%LOCALAPPDATA%\ReFrame\Backups\` before being applied, and `rollback <game>` restores the original state in seconds.

**How is ReFrame different from GeForce Experience, AMD Adrenalin, or MSI Afterburner?**
Those tools manage GPU driver settings. ReFrame targets the game's own configuration files and Windows system settings (HAGS, multimedia scheduler, power plan) — settings those tools do not touch. They complement each other rather than compete.

**Does ReFrame work with Steam, Epic Games Store, and Xbox Game Pass titles?**
Yes. ReFrame searches common installation paths for all three platforms. For games installed elsewhere, use `analyse config <path>` to point it directly at a config file.

**Do I need administrator access?**
ReFrame runs without elevation for config file changes. Registry modifications that require Administrator are shown as ready-to-run PowerShell commands you can paste into an elevated terminal.

**Does ReFrame require an internet connection?**
No. The agent works entirely offline using your local knowledge base and system scan data. An internet connection is only needed for the initial `git clone`.

---

## Related Projects

| Project | Description |
| --- | --- |
| [Symdicate](https://github.com/CTOUT/Symdicate) | Composable multi-agent framework for GitHub Copilot — persona grafting, cognitive identity caching, and agent fusion |
| [vscode-copilot-sync](https://github.com/CTOUT/vscode-copilot-sync) | PowerShell toolkit to sync and manage Copilot agents, instructions, and skills from the awesome-copilot community catalogue |
| [awesome-copilot](https://github.com/github/awesome-copilot) | Community catalogue of Copilot agents, instructions, skills, hooks, and workflows |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities and installer verification guidance.

## License

[MIT](LICENSE)

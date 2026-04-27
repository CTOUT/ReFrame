# Troubleshooting ReFrame

Common problems and how to fix them.

---

## Agent not appearing in Copilot Chat

**Symptom:** `@ReFrame` is not listed in the agent picker or returns "agent not found".

**Causes and fixes:**

1. **VS Code not reloaded after install.** Run `Developer: Reload Window` from the command palette (`Ctrl+Shift+P`), or restart VS Code.

2. **GitHub Copilot Chat extension not installed or outdated.** Open the Extensions panel, search for `GitHub Copilot Chat`, and ensure it is installed and up to date.

3. **Wrong workspace open (repo-level install).** The agent file is at `.github/agents/reframe.agent.md` — it only appears when the ReFrame repo folder is open in VS Code. Open the folder you cloned into.

4. **User-level install path.** The agent should be at `%APPDATA%\Code\User\prompts\reframe.agent.md` on Windows. Verify the file is there. If it was installed on a different machine or profile, reinstall:

```powershell
irm https://raw.githubusercontent.com/CTOUT/ReFrame/main/install.ps1 | iex
```

---

## `scan system` fails or DxDiag errors

**Symptom:** The scan returns `DXDIAG_FAILED` or hangs.

**Causes and fixes:**

1. **DxDiag timeout.** `dxdiag.exe` can take 30–60 seconds on first run while it queries all hardware. If the previous run timed out, delete the cached file and try again:

```powershell
Remove-Item "$env:TEMP\ReFrame-DxDiag.xml" -ErrorAction SilentlyContinue
```

   Then type `scan system` again.

2. **DxDiag unavailable.** Some locked-down or virtualised environments block DxDiag. The agent automatically falls back to PowerShell queries (`Get-CimInstance`, `Get-PhysicalDisk`, `powercfg`). The fallback profile is slightly less detailed but fully functional.

3. **Existing DxDiag file.** If you already have a `DxDiag.xml` export, you can load it directly instead of running a new scan:

```text
load dxdiag C:\Path\To\DxDiag.xml
```

---

## Config files not found for a game

**Symptom:** ReFrame says it cannot find config files, or the broad search returns no results.

**Causes and fixes:**

1. **Non-default install location.** If your Steam library or game install is on a drive other than C:, the broad search may miss it. Point the agent directly:

```text
analyse config D:\SteamLibrary\steamapps\common\GameName\Config\GameUserSettings.ini
```

2. **Game uses a different folder name.** Some games use an abbreviated or localised name in their config path. Check [PCGamingWiki](https://www.pcgamingwiki.com) for the exact path, then use `analyse config <path>`.

3. **Game not yet installed or never launched.** Many games only create their config directory on first launch. Launch the game once (even just to the main menu), exit, then run `optimise <game>` again.

4. **Xbox Game Pass / Game Pass PC.** Game Pass titles often store configs in `%LOCALAPPDATA%\Packages\<PackageName>\` — the package name varies by game. Search manually:

```powershell
Get-ChildItem "$env:LOCALAPPDATA\Packages" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "*.ini" -or $_.Name -like "*.cfg" } |
    Select-Object FullName
```

---

## Registry changes require Administrator

**Symptom:** ReFrame shows registry recommendations but says it cannot apply them, or the changes do not take effect.

**Cause:** The MMCSS, PriorityControl, and HAGS registry paths are under `HKLM` (Local Machine), which requires Administrator rights.

**Fix — Option 1:** Run VS Code as Administrator (right-click the VS Code shortcut → Run as administrator). This is effective but not recommended as a permanent setup.

**Fix — Option 2 (recommended):** ReFrame will show you the exact PowerShell commands. Copy them into a separate PowerShell window opened as Administrator and paste them there:

```powershell
# Right-click Windows Terminal or PowerShell → Run as Administrator, then paste
```

**Note:** A system restart is required for HAGS (`HwSchMode`) and `Win32PrioritySeparation` to take full effect.

---

## Game overwrites config changes after launch

**Symptom:** Settings applied by ReFrame are correct, but the game resets them when launched or when the in-game Graphics menu is opened.

**Cause:** Some games (notably Ark: Survival Evolved, and games with launcher-managed configs) overwrite `GameUserSettings.ini` scalability group keys (`sg.*`) on launch. This is documented as an engine override in the game's knowledge profile.

**Fix:**

1. Use **Engine.ini** CVars instead of `GameUserSettings.ini` for persistent changes where possible. ReFrame will note this for affected games.
2. Apply the desired in-game Graphics settings first, then let ReFrame add Engine.ini tweaks on top.
3. Do not make the config file read-only — this prevents the game from saving other legitimate settings (keybindings, resolution) and may cause crashes.

---

## Knowledge base not being used

**Symptom:** ReFrame says it is using "Engine Default" or "web" for all recommendations, even for games that are listed in `docs/GAMES.md`.

**Cause:** You are using a **user-level install**. The `knowledge/` files live in the repo and are only accessible when the repo is your open workspace.

**Fix:** Use the repo-level install:

```powershell
git clone https://github.com/CTOUT/ReFrame.git
cd ReFrame
.\install.ps1 -Target repo
```

Open the `ReFrame` folder in VS Code. The agent will now read `knowledge/games/` and `knowledge/game-engines/` at runtime.

See [README.md — Installation](../README.md#installation) for full details.

---

## Backup not found or rollback fails

**Symptom:** `rollback <game>` says no backups exist, or restoring a backup fails.

**Causes and fixes:**

1. **Backup directory missing.** Backups are stored in `%LOCALAPPDATA%\ReFrame\Backups\`. Check whether the directory exists:

```powershell
Get-ChildItem "$env:LOCALAPPDATA\ReFrame\Backups" -ErrorAction SilentlyContinue
```

   If empty or missing, no backup was created — either the session was cancelled before applying, or a previous apply failed before the backup step.

2. **Wrong game name.** `rollback <game>` matches against the backup folder name, which uses the game name as supplied. Try `list backups` to see exact folder names.

3. **Manual restore.** If the rollback command fails, restore manually by copying the backed-up file over the original:

```powershell
Copy-Item "$env:LOCALAPPDATA\ReFrame\Backups\<GameName>_<timestamp>\GameUserSettings.ini" `
          "$env:LOCALAPPDATA\<GameFolder>\Saved\Config\WindowsNoEditor\GameUserSettings.ini" -Force
```

---

## Steam Deck, Linux, and macOS

**ReFrame is currently Windows-only.** The following features are unavailable on other platforms:

| Feature | Reason |
| ------- | ------ |
| System scan (`scan system`) | Uses `dxdiag.exe` and `Get-CimInstance` — Windows-only |
| Registry analysis and changes | Windows registry does not exist on Linux / macOS |
| Power plan detection | Uses `powercfg` — Windows-only |
| Hardware tier (HAGS, VRR) | DxDiag attributes used for detection |

**What still works on non-Windows systems:**

- `analyse config <path>` — reading and recommending changes to INI/JSON/XML config files works regardless of OS, as long as the file is accessible
- Knowledge base lookups — game and engine profiles are platform-agnostic for config key recommendations

**Steam Deck specifically:** Steam Deck runs SteamOS (Arch Linux). Config files for Linux-native games and Proton games are typically in `~/.local/share/Steam/steamapps/compatdata/<appid>/pfx/drive_c/users/steamuser/AppData/`. If you can navigate to the config file, `analyse config <path>` will work.

Full non-Windows support (shell-based hardware detection, platform-appropriate config paths) is tracked in [TODO.md](../TODO.md).

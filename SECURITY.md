# Security Policy

## Supported Versions

ReFrame follows [Semantic Versioning](https://semver.org/). Security fixes are applied to the `main` branch and released as new versions.

| Version         | Supported |
| --------------- | --------- |
| `main` (latest) | Yes       |
| Older releases  | No        |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Open a [GitHub Security Advisory](https://github.com/CTOUT/ReFrame/security/advisories/new) to report a vulnerability privately.

Include:

- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept
- Any suggested mitigations

You can expect:

- Acknowledgement within **48 hours**
- A status update within **7 days**
- Credit in the release notes if you would like it

## Scope

This repository contains:

- Agent definitions and steering manifests (`AGENTS.md`, `.agents/skills.json`, `.github/agents/reframe.agent.md`, `.kiro/`) and modular skills (`.github/skills/`)
- An installer script (`install.ps1`)
- GitHub Actions release and validation workflows (`.github/workflows/`)
- Documentation and knowledge base files (`docs/`, `knowledge/`)

Vulnerabilities in any of these are in scope. Areas of particular interest:

- The installer script fetching and executing remote content
- Prompt injection risks in agent instructions
- The agent's use of `execute/runInTerminal` to execute PowerShell — ensure injected user input cannot be passed unsanitised to shell commands
- Registry key paths used by the agent — ensure no path traversal or privilege escalation is possible

## Installer Verification

Pin to a release tag for a reproducible, verifiable install:

```powershell
.\install.ps1 -Ref v1.0.0
```

To verify the installer before running it, download from the releases page and check the SHA-256 against `checksums.sha256`:

```powershell
Invoke-WebRequest -Uri https://github.com/CTOUT/ReFrame/releases/download/v1.0.0/install.ps1 -OutFile install.ps1
Invoke-WebRequest -Uri https://github.com/CTOUT/ReFrame/releases/download/v1.0.0/checksums.sha256 -OutFile checksums.sha256
$expected = (Get-Content checksums.sha256 | Select-String "install.ps1").ToString().Split()[0]
$actual   = (Get-FileHash install.ps1 -Algorithm SHA256).Hash.ToLower()
if ($actual -eq $expected) { "Verified" } else { "MISMATCH — do not run" }
```

## Agent Security Notes

ReFrame uses `execute/runInTerminal` to execute PowerShell for hardware detection and registry operations. The agent instructions enforce:

- Registry changes use `Set-ItemProperty` only — no `Remove-Item`, `Remove-ItemProperty`, or `reg delete`
- All PowerShell commands in the agent use only well-known registry paths with no dynamic path construction from user input
- The agent requires explicit user confirmation before any write operation
- Game names are sanitised before use in backup path construction (strips `\/:*?"<>|` and `..` sequences)
- Game names are escaped with `[WildcardPattern]::Escape()` before use in `-like` file search patterns

## GitHub Actions

The workflows (`release.yml` and `spellcheck.yml`) pin all actions to full commit SHAs to prevent supply-chain compromise via mutable tags:

| Action                        | SHA                                        | Tag    |
| ----------------------------- | ------------------------------------------ | ------ |
| `actions/checkout`            | `3d3c42e5aac5ba805825da76410c181273ba90b1` | v7.0.1 |
| `actions/setup-node`          | `949feb2413d6458794dcd2491c4babbbce0c15c1` | v7.1.0 |
| `softprops/action-gh-release` | `efb35369e0ad2afab669f228072c1b0d510eae64` | v3.0.3 |

When updating any action, replace the SHA with the new release's commit SHA — do not revert to a mutable tag reference.

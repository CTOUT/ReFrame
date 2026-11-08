#Requires -Version 5.1
<#
.SYNOPSIS
    Install the ReFrame game configuration optimisation agent for GitHub Copilot, Google Antigravity, or Kiro.

.DESCRIPTION
    Downloads and installs ReFrame agent definitions and steering/skill manifests
    for GitHub Copilot (VS Code), Google Antigravity (AGY), Kiro, or all three platforms.
    Supports both user-level (global) and repo-level (workspace) installations.

.PARAMETER Target
    Installation target. 'user' (default) or 'repo'.

.PARAMETER Platform
    Target AI agent platform: 'copilot' (default), 'antigravity', 'kiro', or 'all'.

.PARAMETER Ref
    Git ref (tag, branch, or commit SHA) to install from. Defaults to 'main'.
    Pin to a release tag for reproducible installs: -Ref v1.2.0

.PARAMETER DryRun
    Show what would happen without writing any files.

.PARAMETER Uninstall
    Remove the installed ReFrame agent files for the selected platform(s).

.EXAMPLE
    irm https://raw.githubusercontent.com/CTOUT/ReFrame/main/install.ps1 | iex

.EXAMPLE
    # Recommended — repo-level install for all platforms (Copilot, Antigravity, Kiro):
    git clone https://github.com/CTOUT/ReFrame.git; cd ReFrame; .\install.ps1 -Target repo -Platform all

.EXAMPLE
    # Install globally for Google Antigravity and Kiro:
    .\install.ps1 -Target user -Platform all

.EXAMPLE
    .\install.ps1 -Target repo -Platform antigravity -Ref v1.2.0

.EXAMPLE
    .\install.ps1 -DryRun -Platform all
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('user', 'repo')]
    [string]$Target = 'user',

    [ValidateSet('copilot', 'antigravity', 'kiro', 'all')]
    [string]$Platform = 'copilot',

    [ValidatePattern('^[a-zA-Z0-9._/-]+$')]
    [string]$Ref = 'main',

    [switch]$DryRun,
    [switch]$Uninstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Guard against path traversal in the Ref parameter — '..' could redirect the
# download to an arbitrary GitHub repository path.
if ($Ref -match '\.\.') {
    throw "Invalid -Ref value '$Ref': must not contain '..'"
}

# Enforce TLS 1.2 / 1.3 for older PowerShell versions
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$rawRoot = "https://raw.githubusercontent.com/CTOUT/ReFrame/$Ref"
$cwd = (Get-Location).Path
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

$vscodePromptsPath = switch ($true) {
    ($IsLinux) { "$homeDir/.config/Code/User/prompts" }
    ($IsMacOS) { "$homeDir/Library/Application Support/Code/User/prompts" }
    default { "$env:APPDATA\Code\User\prompts" }
}

$platformsToProcess = if ($Platform -eq 'all') {
    @('copilot', 'antigravity', 'kiro')
}
else {
    @($Platform)
}

# Build file mapping list: SourceRelPath, DestPath, PlatformName
$installItems = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($plat in $platformsToProcess) {
    switch ($plat) {
        'copilot' {
            $dest = if ($Target -eq 'repo') {
                Join-Path $cwd '.github\agents\reframe.agent.md'
            }
            else {
                Join-Path $vscodePromptsPath 'reframe.agent.md'
            }
            $installItems.Add([PSCustomObject]@{
                Platform      = 'copilot'
                SourceRelPath = '.github/agents/reframe.agent.md'
                DestPath      = $dest
                WrapAsSkill   = $false
            })
        }
        'antigravity' {
            if ($Target -eq 'repo') {
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'antigravity'
                    SourceRelPath = 'AGENTS.md'
                    DestPath      = Join-Path $cwd 'AGENTS.md'
                    WrapAsSkill   = $false
                })
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'antigravity'
                    SourceRelPath = '.agents/skills.json'
                    DestPath      = Join-Path $cwd '.agents\skills.json'
                    WrapAsSkill   = $false
                })
            }
            else {
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'antigravity'
                    SourceRelPath = 'AGENTS.md'
                    DestPath      = Join-Path $homeDir '.gemini\config\skills\reframe\SKILL.md'
                    WrapAsSkill   = $true
                })
            }
        }
        'kiro' {
            if ($Target -eq 'repo') {
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'kiro'
                    SourceRelPath = 'AGENTS.md'
                    DestPath      = Join-Path $cwd 'AGENTS.md'
                    WrapAsSkill   = $false
                })
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'kiro'
                    SourceRelPath = '.kiro/agents/reframe.json'
                    DestPath      = Join-Path $cwd '.kiro\agents\reframe.json'
                    WrapAsSkill   = $false
                })
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'kiro'
                    SourceRelPath = '.kiro/steering/reframe.md'
                    DestPath      = Join-Path $cwd '.kiro\steering\reframe.md'
                    WrapAsSkill   = $false
                })
            }
            else {
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'kiro'
                    SourceRelPath = '.github/agents/reframe.agent.md'
                    DestPath      = Join-Path $homeDir '.kiro\agents\reframe.md'
                    WrapAsSkill   = $false
                })
                $installItems.Add([PSCustomObject]@{
                    Platform      = 'kiro'
                    SourceRelPath = '.kiro/agents/reframe.json'
                    DestPath      = Join-Path $homeDir '.kiro\agents\reframe.json'
                    WrapAsSkill   = $false
                })
            }
        }
    }
}

# Deduplicate by DestPath (e.g. AGENTS.md when installing both antigravity and kiro at repo level)
$uniqueItems = $installItems | Group-Object -Property DestPath | ForEach-Object { $_.Group[0] }

# --- Uninstall ---
if ($Uninstall) {
    foreach ($item in $uniqueItems) {
        if (Test-Path $item.DestPath) {
            if ($DryRun) {
                Write-Host "[DryRun] Would remove: $($item.DestPath)"
            }
            else {
                Remove-Item $item.DestPath -Force
                Write-Host "Removed: $($item.DestPath)"
            }
        }
        else {
            Write-Host "Not installed at: $($item.DestPath)"
        }
    }
    return
}

# --- Install ---
Write-Host "ReFrame installer (Target: $Target | Platform: $Platform | Ref: $Ref)"
foreach ($item in $uniqueItems) {
    Write-Host "  [$($item.Platform)] $rawRoot/$($item.SourceRelPath) -> $($item.DestPath)"
}

if ($DryRun) {
    Write-Host "[DryRun] No files written."
    return
}

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    foreach ($item in $uniqueItems) {
        $destDir = Split-Path -Path $item.DestPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $localCandidate = Join-Path $cwd ($item.SourceRelPath -replace '/', '\')
        $tempFile = Join-Path $tempDir ([System.IO.Path]::GetRandomFileName())
        $sourceUrl = "$rawRoot/$($item.SourceRelPath)"

        try {
            Invoke-WebRequest -Uri $sourceUrl -OutFile $tempFile -UseBasicParsing -TimeoutSec 30
        }
        catch {
            # Only fall back to local working tree when installing repo-level from 'main'.
            # Never fall back when a pinned -Ref tag/SHA was requested for supply-chain verification.
            if ($Target -eq 'repo' -and $Ref -eq 'main' -and (Test-Path $localCandidate)) {
                Copy-Item -Path $localCandidate -Destination $tempFile -Force
            }
            else {
                throw
            }
        }

        if ($item.WrapAsSkill) {
            $body = Get-Content -Path $tempFile -Raw -Encoding UTF8
            $skillHeader = @(
                '---'
                'name: reframe'
                'description: Game configuration optimisation agent. Detects system hardware, analyses game config files and Windows registry settings, and applies improvements with backup, rollback, and named profile switching.'
                '---'
                ''
            ) -join "`n"
            [System.IO.File]::WriteAllText($item.DestPath, ($skillHeader + $body), [System.Text.UTF8Encoding]::new($false))
        }
        else {
            Copy-Item -Path $tempFile -Destination $item.DestPath -Force
        }

        Write-Host "Installed: $($item.DestPath)"
    }

    Write-Host ""
    if ($Target -eq 'user') {
        Write-Host "Note: user-level installs do not include the knowledge/ directory."
        Write-Host "      Game-specific profiles and per-engine JSON defaults are unavailable."
        Write-Host "      For full knowledge base coverage, clone the repo and use -Target repo."
        Write-Host ""
    }
    Write-Host "Installation complete for platform(s): $($platformsToProcess -join ', ')."
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

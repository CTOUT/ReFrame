#Requires -Version 5.1
<#
.SYNOPSIS
    Install the ReFrame game configuration optimisation agent for GitHub Copilot.

.DESCRIPTION
    Downloads and installs reframe.agent.md into the VS Code user prompts folder
    (user-level install, default) or into .github/agents/ (repo-level install).

.PARAMETER Target
    Installation target. 'user' (default) or 'repo'.

.PARAMETER Ref
    Git ref (tag, branch, or commit SHA) to install from. Defaults to 'main'.
    Pin to a release tag for reproducible installs: -Ref v1.0.0

.PARAMETER DryRun
    Show what would happen without writing any files.

.PARAMETER Uninstall
    Remove the installed ReFrame agent file.

.EXAMPLE
    irm https://raw.githubusercontent.com/CTOUT/ReFrame/main/install.ps1 | iex

.EXAMPLE
    # Recommended — repo-level install with full knowledge base:
    git clone https://github.com/CTOUT/ReFrame.git; cd ReFrame; .\install.ps1 -Target repo

.EXAMPLE
    .\install.ps1 -Target repo -Ref v1.0.0

.EXAMPLE
    .\install.ps1 -DryRun
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('user', 'repo')]
    [string]$Target = 'user',

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

# --- Paths ---
$agentFileName = 'reframe.agent.md'
$rawBase = "https://raw.githubusercontent.com/CTOUT/ReFrame/$Ref/.github/agents"

$userPromptsPath = switch ($true) {
    ($IsLinux) { "$HOME/.config/Code/User/prompts" }
    ($IsMacOS) { "$HOME/Library/Application Support/Code/User/prompts" }
    default { "$env:APPDATA\Code\User\prompts" }
}

$installPath = if ($Target -eq 'repo') {
    Join-Path (Get-Location) '.github\agents'
}
else {
    $userPromptsPath
}

$destFile = Join-Path $installPath $agentFileName

# --- Uninstall ---
if ($Uninstall) {
    if (Test-Path $destFile) {
        if ($DryRun) {
            Write-Host "[DryRun] Would remove: $destFile"
        }
        else {
            Remove-Item $destFile -Force
            Write-Host "Removed: $destFile"
        }
    }
    else {
        Write-Host "Not installed at: $destFile"
    }
    return
}

# --- Download ---
$sourceUrl = "$rawBase/$agentFileName"

Write-Host "ReFrame installer"
Write-Host "  Source : $sourceUrl"
Write-Host "  Target : $destFile"

if ($DryRun) {
    Write-Host "[DryRun] No files written."
    return
}

if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

# Download to a private temp directory
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$tempFile = Join-Path $tempDir $agentFileName

try {
    Invoke-WebRequest -Uri $sourceUrl -OutFile $tempFile -UseBasicParsing -TimeoutSec 30
    Copy-Item -Path $tempFile -Destination $destFile -Force
    Write-Host "Installed: $destFile"
    Write-Host ""
    if ($Target -eq 'user') {
        Write-Host "Note: user-level installs do not include the knowledge base."
        Write-Host "      Game-specific profiles and per-engine JSON defaults are unavailable."
        Write-Host "      The agent will use embedded engine defaults and web lookups."
        Write-Host "      For full knowledge base coverage, clone the repo and use -Target repo."
        Write-Host ""
    }
    Write-Host "Restart VS Code (or run 'Developer: Reload Window') to load the agent."
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

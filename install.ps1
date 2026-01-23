# install.ps1
# Stateless, idempotent dotfiles installer
#
# Modes:
#   default  → install
#   -DryRun  → show actions, no changes
#   -Check   → verify state, no changes
#
# Rules:
# - No bookkeeping
# - Safe re-runs
# - Overwrites ONLY repo-owned symlinks
# - Use -Force to overwrite foreign targets
# - Supports files and directories
#
# Usage:
#   .\install.ps1
#   .\install.ps1 -DryRun
#   .\install.ps1 -Check
#   .\install.ps1 -Force

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Check,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
$RepoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot = Join-Path $RepoRoot 'dotfiles'
$MapFile      = Join-Path $RepoRoot 'dotfiles.map.json'

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
function Info($m)
{ Write-Host "[INFO]  $m" -ForegroundColor Cyan
}
function Warn($m)
{ Write-Host "[WARN]  $m" -ForegroundColor Yellow
}
function Err ($m)
{ Write-Host "[ERROR] $m" -ForegroundColor Red
}

# ------------------------------------------------------------
# Platform detection
# ------------------------------------------------------------
function Get-Platform
{
    if ($IsWindows)
    { return 'windows'
    }
    if ($IsLinux)
    { return 'linux'
    }
    if ($IsMacOS)
    { return 'macos'
    }
    return 'unknown'
}

# ------------------------------------------------------------
# Path helpers
# ------------------------------------------------------------
function Resolve-HomePath
{
    param([Parameter(Mandatory)][string]$Path)

    if ($Path -like "~/*")
    {
        return Join-Path $HOME $Path.Substring(2)
    }
    return $Path
}

function Ensure-Directory
{
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path))
    {
        if ($DryRun -or $Check)
        {
            Info "Would create directory: $Path"
        } else
        {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Info "Created directory: $Path"
        }
    }
}

# ------------------------------------------------------------
# Repo ownership detection (no bookkeeping)
# ------------------------------------------------------------
function Is-RepoOwnedLink
{
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$RepoRoot
    )

    if (-not (Test-Path $Target))
    {
        return $false
    }

    try
    {
        $item = Get-Item $Target -ErrorAction Stop
        if (-not $item.LinkType)
        {
            return $false
        }

        $resolved = (Resolve-Path $Target).Path
        return $resolved.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)
    } catch
    {
        return $false
    }
}

# ------------------------------------------------------------
# Install / Check link (file or directory)
# ------------------------------------------------------------
function Process-Entry
{
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target
    )

    $exists    = Test-Path $Target
    $repoOwned = $exists -and (Is-RepoOwnedLink -Target $Target -RepoRoot $RepoRoot)

    if ($Check)
    {
        if (-not $exists)
        {
            Warn "MISSING : $Target"
            return
        }

        if (-not $repoOwned)
        {
            Warn "FOREIGN : $Target"
            return
        }

        Info "OK      : $Target"
        return
    }

    if ($exists -and -not $repoOwned -and -not $Force)
    {
        Warn "Target exists and is not repo-owned, skipping: $Target"
        return
    }

    if ($exists)
    {
        if ($DryRun)
        {
            Info "Would remove existing target: $Target"
        } else
        {
            Remove-Item $Target -Recurse -Force
            Info "Removed existing target: $Target"
        }
    }

    Ensure-Directory (Split-Path -Parent $Target)

    if ($DryRun)
    {
        Info "Would link: $Target -> $Source"
        return
    }

    if ($IsWindows)
    {
        try
        {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
        } catch
        {
            Warn "Symlink failed, falling back to copy: $Target"
            Copy-Item -Path $Source -Destination $Target -Recurse -Force
        }
    } else
    {
        & ln -sfn $Source $Target
    }

    Info "Linked: $Target -> $Source"
}

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
if (-not (Test-Path $MapFile))
{
    Err "Mapping file not found: $MapFile"
    exit 1
}

# ------------------------------------------------------------
# Load mapping
# ------------------------------------------------------------
$Map      = Get-Content $MapFile -Raw | ConvertFrom-Json
$Platform = Get-Platform

Info "Platform : $Platform"
Info "Mode     : $(if ($Check) {'CHECK'} elseif ($DryRun) {'DRY-RUN'} else {'INSTALL'})"
Info "Force    : $Force"

# ------------------------------------------------------------
# Process mappings
# ------------------------------------------------------------
foreach ($key in $Map.PSObject.Properties.Name)
{
    $entry = $Map.$key

    if ($entry.platforms -and -not ($entry.platforms -contains $Platform))
    {
        Info "Skipping (platform mismatch): $key"
        continue
    }

    $Source = Join-Path $DotfilesRoot $key
    if (-not (Test-Path $Source))
    {
        Warn "Source missing, skipping: $Source"
        continue
    }

    $Target = Resolve-HomePath $entry.target

    Info "Processing: $key"
    Process-Entry -Source $Source -Target $Target
}

Info "Done."

# install.ps1
# Stateless dotfiles installer with:
# - files + folders
# - check mode
# - dry-run mode
# - automatic backup of foreign targets
# - timestamped transcript per run
# - no modules, no bookkeeping
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
# Paths & run context
# ------------------------------------------------------------
$RepoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot = Join-Path $RepoRoot 'dotfiles'
$MapFile      = Join-Path $RepoRoot 'dotfiles.map.json'

$BackupRoot   = Join-Path $RepoRoot '.backup'
$Timestamp    = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$BackupRunDir = Join-Path $BackupRoot $Timestamp
$Transcript   = Join-Path $BackupRunDir 'transcript.txt'

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
    param([string]$Path)
    if ($Path -like "~/*")
    {
        return Join-Path $HOME $Path.Substring(2)
    }
    return $Path
}

function Ensure-Directory($Path)
{
    if (-not (Test-Path $Path))
    {
        if ($DryRun -or $Check)
        {
            Info "Would create directory: $Path"
        } else
        {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
    }
}

# ------------------------------------------------------------
# Repo-owned symlink detection
# ------------------------------------------------------------
function Is-RepoOwnedLink
{
    param([string]$Target)

    try
    {
        $item = Get-Item $Target -ErrorAction Stop
        if (-not $item.LinkType)
        { return $false
        }

        return (Resolve-Path $Target).Path.StartsWith(
            $RepoRoot,
            [StringComparison]::OrdinalIgnoreCase
        )
    } catch
    {
        return $false
    }
}

# ------------------------------------------------------------
# Backup foreign targets
# ------------------------------------------------------------
function Backup-Target
{
    param([string]$Target)

    # normalize path for backup layout
    $relative = $Target -replace '^[A-Za-z]:\\', ''
    $backupPath = Join-Path $BackupRunDir $relative
    $backupDir  = Split-Path -Parent $backupPath

    Ensure-Directory $backupDir

    if ($DryRun)
    {
        Info "Would backup: $Target -> $backupPath"
        return
    }

    Copy-Item -Path $Target -Destination $backupPath -Recurse -Force
    Info "Backed up: $Target"
}

# ------------------------------------------------------------
# Process a single mapping entry (file or folder)
# ------------------------------------------------------------
function Process-Entry
{
    param(
        [string]$Source,
        [string]$Target
    )

    $exists    = Test-Path $Target
    $repoOwned = $exists -and (Is-RepoOwnedLink $Target)

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

    if ($exists -and -not $repoOwned)
    {
        if (-not $Force)
        {
            Backup-Target $Target
        }

        if ($DryRun)
        {
            Info "Would remove foreign target: $Target"
        } else
        {
            Remove-Item $Target -Recurse -Force
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
# Prepare backup + transcript (not in CHECK mode)
# ------------------------------------------------------------
if (-not $Check)
{
    Ensure-Directory $BackupRunDir
    Start-Transcript -Path $Transcript | Out-Null
}

try
{
    # --------------------------------------------------------
    # Load mapping
    # --------------------------------------------------------
    $Map      = Get-Content $MapFile -Raw | ConvertFrom-Json
    $Platform = Get-Platform

    Info "Mode     : $(if ($Check) {'CHECK'} elseif ($DryRun) {'DRY-RUN'} else {'INSTALL'})"
    Info "Platform : $Platform"

    # --------------------------------------------------------
    # Process mappings
    # --------------------------------------------------------
    foreach ($key in $Map.PSObject.Properties.Name)
    {
        $entry = $Map.$key

        if ($entry.platforms -and -not ($entry.platforms -contains $Platform))
        {
            continue
        }

        $Source = Join-Path $DotfilesRoot $key
        if (-not (Test-Path $Source))
        {
            Warn "Source missing: $Source"
            continue
        }

        $Target = Resolve-HomePath $entry.target

        Info "Processing: $key"
        Process-Entry -Source $Source -Target $Target
    }

    Info "Done."
} finally
{
    if (-not $Check)
    {
        Stop-Transcript | Out-Null
    }
}

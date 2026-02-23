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
Set-StrictMode -Version Latest

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
$TranscriptStarted = $false

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
function Info($m)
{ Write-Information "[INFO]  $m" -InformationAction Continue
}
function Warn($m)
{ Write-Warning $m
}
function Err ($m)
{ Write-Error $m
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
    if ($Path -like "~/*" -or $Path -like "~\*")
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
    $relative = $relative.TrimStart('\','/')
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
        if ($Force)
        { Info "Force enabled; backing up then overwriting: $Target"
        }
        Backup-Target $Target

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
        if ($LASTEXITCODE -ne 0)
        { throw "ln failed with exit code $LASTEXITCODE for $Target"
        }
    }

    Info "Linked: $Target -> $Source"

    # If running on non-Windows and the source is a regular file that looks
    # like a script (shebang), has a common script extension, or already has
    # an executable bit, ensure the real file is executable. Prefer setting
    # the executable bit on the repository source (the real file behind the
    # symlink). If the installer ever copies instead of linking, the target
    # will be chmod'd instead.
    if (-not $IsWindows -and (Test-Path $Source -PathType Leaf))
    {
        $firstLine = Get-Content -Path $Source -TotalCount 1 -ErrorAction SilentlyContinue
        $sourceItem = Get-Item $Source -ErrorAction SilentlyContinue
        $hasExec = $false

        if ($firstLine -and $firstLine -match '^#!') { $hasExec = $true }

        $ext = [System.IO.Path]::GetExtension($Source).TrimStart('.')
        $ext = if ($ext) { $ext.ToLowerInvariant() } else { '' }
        $scriptExts = @('sh','bash','zsh','ksh','py','pl','rb','awk','sed','ps1','js')
        if ($scriptExts -contains $ext) { $hasExec = $true }

        if ($sourceItem -and ($sourceItem.Mode -and ($sourceItem.Mode -match 'x'))) { $hasExec = $true }

        if ($hasExec)
        {
            if ($DryRun)
            {
                Info "Would set executable on source: $Source"
            } else
            {
                # Prefer chmod on the source (the repo file) so symlinked targets
                # inherit executability. If the source doesn't exist but the
                # target is a regular file (e.g., copied), chmod target instead.
                if (Test-Path $Source)
                {
                    & chmod +x -- $Source
                }
                elseif (Test-Path $Target)
                {
                    & chmod +x -- $Target
                }

                if ($LASTEXITCODE -ne 0)
                { Warn "chmod failed"
                }
            }
        }
    }
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
    try
    { Start-Transcript -Path $Transcript | Out-Null
      $TranscriptStarted = $true
    } catch
    { throw "Failed to start transcript at $Transcript. $($_.Exception.Message)"
    }
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

    foreach ($p in $Map.PSObject.Properties)
    {
        if (-not $p.Value.target -or -not ($p.Value.target -is [string]))
        { throw "Invalid map entry for key '$($p.Name)': target is required and must be a string."
        }
    }

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
    if (-not $Check -and $TranscriptStarted)
    {
        Stop-Transcript | Out-Null
    }
}

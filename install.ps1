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
    [switch]$Force,
    [string]$Only,
    [switch]$Uninstall
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
        $root = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd('\', '/')
        $comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
        $separator = [System.IO.Path]::DirectorySeparatorChar
        $rootPrefix = $root + $separator
        $seen = if ($IsWindows)
        { [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase) }
        else
        { [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal) }
        $current = [System.IO.Path]::GetFullPath($Target)

        while ($true)
        {
            if (-not $seen.Add($current)) { return $false }
            $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
            if ($null -eq $item)
            {
                return $seen.Count -gt 1 -and ($current.Equals($root, $comparison) -or $current.StartsWith($rootPrefix, $comparison))
            }
            if (-not $item.LinkType)
            {
                break
            }

            $linkTarget = @($item.Target) | Select-Object -First 1
            if ([string]::IsNullOrEmpty($linkTarget)) { return $false }
            if (-not [System.IO.Path]::IsPathRooted($linkTarget))
            {
                $linkTarget = Join-Path (Split-Path -Parent $current) $linkTarget
            }
            $current = [System.IO.Path]::GetFullPath($linkTarget)
        }

        return $current.Equals($root, $comparison) -or $current.StartsWith($rootPrefix, $comparison)
    } catch { return $false }
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

    $targetItem = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    $exists    = $null -ne $targetItem
    $repoOwned = $exists -and (Is-RepoOwnedLink $Target)

    if ($Check)
    {
        if (-not $exists)
        {
            Warn "MISSING : $Target"
            $script:ErrorCount++
            return
        }
        if (-not $repoOwned)
        {
            Warn "FOREIGN : $Target"
            $script:ErrorCount++
            return
        }
        if (-not (Test-Path -LiteralPath $Target -ErrorAction SilentlyContinue))
        {
            Warn "BROKEN  : $Target"
            $script:ErrorCount++
            return
        }
        Info "OK      : $Target"
        return
    }

    if ($exists -and -not $repoOwned)
    {
        if (-not $Force)
        {
            Warn "Refusing to replace foreign target without -Force: $Target"
            $script:ErrorCount++
            return
        }
        Backup-Target $Target

        if ($DryRun) { Info "Would remove foreign target: $Target" }
        else { Remove-Item $Target -Recurse -Force }
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

    # Repository sources keep their committed executable mode unchanged.
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
if (-not $Check -and -not $DryRun)
{
    Ensure-Directory $BackupRunDir
    try
    {
        Start-Transcript -Path $Transcript | Out-Null
        $TranscriptStarted = $true
    } catch { throw "Failed to start transcript at $Transcript. $($_.Exception.Message)" }
}

try
{
    $Map = Get-Content $MapFile -Raw | ConvertFrom-Json
    $Platform = Get-Platform
    $script:ErrorCount = 0
    if ($Uninstall -and $Check) { throw "-Uninstall cannot be combined with -Check." }

    Info "Mode     : $(if ($Check) {'CHECK'} elseif ($DryRun) {'DRY-RUN'} else {'INSTALL'})"
    Info "Platform : $Platform"

    foreach ($p in $Map.PSObject.Properties)
    {
        if (-not $p.Value.target -or -not ($p.Value.target -is [string]))
        { throw "Invalid map entry for key '$($p.Name)': target is required and must be a string." }
        if ($Only -and $p.Name -ne $Only) { continue }
        if ($p.Value.platforms -and -not ($p.Value.platforms -contains $Platform)) { continue }
        $Source = Join-Path $DotfilesRoot $p.Name
        $Target = Resolve-HomePath $p.Value.target
        if ($Uninstall)
        {
            if (Is-RepoOwnedLink $Target)
            {
                if ($DryRun) { Info "Would remove repo-owned target: $Target" }
                else { Remove-Item $Target -Force -Recurse; Info "Removed: $Target" }
            }
            continue
        }
        if (-not (Test-Path $Source))
        {
            Warn "Source missing: $Source"
            $script:ErrorCount++
            continue
        }
        Info "Processing: $($p.Name)"
        Process-Entry -Source $Source -Target $Target
    }

    if ($script:ErrorCount -gt 0) { exit 1 }
    Info "Done."
} finally
{
    if ($TranscriptStarted) { Stop-Transcript | Out-Null }
}

# add-dotfile.ps1
# Helper to add files OR directories to the dotfiles repo
#
# Behavior:
# - Copies file or directory into dotfiles/
# - Updates dotfiles.map.json
# - Never modifies the live system
#
# Usage:
#   File:
#     .\add-dotfile.ps1 -Source "$HOME\.gitconfig" -Key "git/.gitconfig" -Target "~/.gitconfig"
#
#   Folder:
#     .\add-dotfile.ps1 -Source "$HOME\.config\nvim" -Key "nvim" -Target "~/.config/nvim"

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Key,

    [Parameter(Mandatory)]
    [string]$Target,

    [string[]]$Platforms = @('windows', 'linux', 'macos')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

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
# Paths
# ------------------------------------------------------------
$RepoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot = Join-Path $RepoRoot 'dotfiles'
$MapFile      = Join-Path $RepoRoot 'dotfiles.map.json'

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
if (-not (Test-Path $Source))
{
    throw "Source not found: $Source"
}

if (-not (Test-Path $DotfilesRoot))
{
    throw "dotfiles/ directory missing"
}

# Validate key (no absolute paths or traversal)
if ($Key -match '^\s*[\\/]' -or $Key -match '\.\.')
{
    throw "Key must be a relative path without '..': $Key"
}

# Validate platforms
$validPlatforms = @('windows', 'linux', 'macos')
foreach ($p in $Platforms)
{
    if ($validPlatforms -notcontains $p)
    {
        throw "Invalid platform: $p"
    }
}

# ------------------------------------------------------------
# Load or init mapping
# ------------------------------------------------------------
if (Test-Path $MapFile)
{
    $Map = Get-Content $MapFile -Raw | ConvertFrom-Json
} else
{
    $Map = @{}
}

if ($Map.PSObject.Properties.Name -contains $Key)
{
    throw "Mapping already exists for key: $Key"
}

# ------------------------------------------------------------
# Resolve symlinks (safety check outside HOME)
# ------------------------------------------------------------
$sourceItem = Get-Item -LiteralPath $Source
$copySource = $Source
if ($sourceItem.LinkType)
{
    $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
    $homeResolved = (Resolve-Path -LiteralPath $HOME).Path
    $comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
    if (-not $resolvedSource.StartsWith($homeResolved, $comparison))
    {
        Warn "Symlink target is outside HOME: $resolvedSource"
        $confirm = Read-Host "Continue and copy target contents? (y/N)"
        if ($confirm -notin @('y','Y','yes','YES'))
        {
            throw "Aborted by user."
        }
    }
    $copySource = $resolvedSource
}

# ------------------------------------------------------------
# Copy into repo (file OR directory)
# ------------------------------------------------------------
$RepoPath = Join-Path $DotfilesRoot $Key
$RepoDir  = Split-Path -Parent $RepoPath

if (Test-Path $RepoPath)
{
    throw "Destination already exists: $RepoPath"
}

New-Item -ItemType Directory -Path $RepoDir -Force | Out-Null

if ((Get-Item $copySource).PSIsContainer)
{
    if ((Get-Command Copy-Item).Parameters.ContainsKey('FollowSymlink'))
    {
        Copy-Item -Path $copySource -Destination $RepoPath -Recurse -Force -FollowSymlink
    } else
    {
        Copy-Item -Path $copySource -Destination $RepoPath -Recurse -Force
    }
    Info "Added directory: dotfiles/$Key"
} else
{
    Copy-Item -Path $copySource -Destination $RepoPath -Force
    Info "Added file: dotfiles/$Key"
}

# ------------------------------------------------------------
# Add mapping entry
# ------------------------------------------------------------
$Map | Add-Member -MemberType NoteProperty -Name $Key -Value @{
    target    = $Target
    platforms = $Platforms
}

$Map |
    ConvertTo-Json -Depth 5 |
    Set-Content $MapFile -Encoding UTF8

Info "Updated dotfiles.map.json"

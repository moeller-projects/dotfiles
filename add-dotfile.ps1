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

# ------------------------------------------------------------
# Copy into repo (file OR directory)
# ------------------------------------------------------------
$RepoPath = Join-Path $DotfilesRoot $Key
$RepoDir  = Split-Path -Parent $RepoPath

New-Item -ItemType Directory -Path $RepoDir -Force | Out-Null

if ((Get-Item $Source).PSIsContainer)
{
    Copy-Item -Path $Source -Destination $RepoPath -Recurse -Force
    Write-Host "[OK] Added directory: dotfiles/$Key" -ForegroundColor Green
} else
{
    Copy-Item -Path $Source -Destination $RepoPath -Force
    Write-Host "[OK] Added file: dotfiles/$Key" -ForegroundColor Green
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
# Add mapping entry
# ------------------------------------------------------------
$Map | Add-Member -MemberType NoteProperty -Name $Key -Value @{
    target    = $Target
    platforms = $Platforms
}

$Map |
    ConvertTo-Json -Depth 5 |
    Set-Content $MapFile -Encoding UTF8

Write-Host "[OK] Updated dotfiles.map.json" -ForegroundColor Green

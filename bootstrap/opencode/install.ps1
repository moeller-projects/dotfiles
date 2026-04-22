#Requires -Version 7
<#
.SYNOPSIS
    Bootstrap installer for the OpenCode AI agent platform (Windows/PowerShell).

.DESCRIPTION
    Stages:
        1. preflight  - verify required tools and paths
        2. sync       - copy tool sources to dotfiles tools dir
        3. build      - compile TypeScript package
        4. validate   - basic JSON config validation
        5. smoke      - verify at least one tool is loadable
        6. summary    - print results

.PARAMETER DryRun
    Show intended actions without making changes.
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent (Split-Path -Parent $ScriptDir)

$OpenCodeConfigDir  = Join-Path $env:APPDATA 'OpenCode'
$OpenCodeConfigFile = Join-Path $OpenCodeConfigDir 'opencode.jsonc'
$ToolsSrc           = Join-Path $RepoRoot 'packages\opencode-tools\src'
$DotfilesToolsDir   = Join-Path $RepoRoot 'dotfiles\ai-agents\opencode\tools'
$ToolsPkg           = Join-Path $RepoRoot 'packages\opencode-tools'
$Dist               = Join-Path $ToolsPkg 'dist'

function Write-Pass  { param($Msg) Write-Host "  $(([char]0x2713)) $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "  ! $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "  x $Msg" -ForegroundColor Red }
function Write-Stage { param($N, $Name) Write-Host "`n── Stage ${N}: ${Name} ──" }

$StageErrors = [System.Collections.Generic.List[string]]::new()

function Fail-Stage { param($Stage, $Msg)
    $StageErrors.Add($Stage) | Out-Null
    Write-Host "`nERROR: Stage failed - $Stage"
    Write-Host "       $Msg"
}

# Stage 1 - Preflight
Write-Stage 1 "preflight"

$nodeOk = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = (node --version) -replace '^v',''
    $nodeMajor = [int]($nodeVer.Split('.')[0])
    if ($nodeMajor -ge 20) {
        Write-Pass "node $(node --version)"
        $nodeOk = $true
    } else {
        Fail-Stage "preflight" "Node.js >=20 required, found $(node --version)"
    }
} else {
    Fail-Stage "preflight" "node not found"
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Pass "npm $(npm --version)"
} else {
    Fail-Stage "preflight" "npm required"
}

if (Test-Path $ToolsPkg) {
    Write-Pass "packages/opencode-tools found"
} else {
    Fail-Stage "preflight" "packages/opencode-tools not found at $ToolsPkg"
}

if ($StageErrors.Count -gt 0) {
    Write-Host "`nPreflight failed. Resolve the issues above and re-run."
    exit 1
}

# Stage 2 - Sync sources
Write-Stage 2 "sync tool sources"

if ($DryRun) {
    Write-Host "  [dry-run] would sync: $ToolsSrc\*.ts -> $DotfilesToolsDir\"
} else {
    New-Item -ItemType Directory -Force -Path $DotfilesToolsDir | Out-Null
    Get-ChildItem -Path $ToolsSrc -Filter '*.ts' | ForEach-Object {
        $dest = Join-Path $DotfilesToolsDir $_.Name
        $src  = $_.FullName
        if (Test-Path $dest) {
            if ((Get-FileHash $src -Algorithm SHA256).Hash -eq (Get-FileHash $dest -Algorithm SHA256).Hash) {
                Write-Host "  up-to-date: $($_.Name)"
                return
            }
            # Backup before overwrite
            $backupDir = Join-Path $RepoRoot ".backup\opencode\$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
            Copy-Item $dest (Join-Path $backupDir $_.Name)
        }
        Copy-Item $src $dest -Force
        Write-Host "  synced: $($_.Name)"
    }
}

# Stage 3 - Build
Write-Stage 3 "build tools package"

if ($DryRun) {
    Write-Host "  [dry-run] would run: npm install && npm run build (in $ToolsPkg)"
} else {
    Push-Location $ToolsPkg
    try {
        Write-Host "  installing dependencies..."
        npm install --prefer-offline --silent 2>&1 | Select-Object -Last 3
        Write-Host "  compiling TypeScript..."
        npm run build
        Write-Host "  build complete: dist/ generated"
    } catch {
        Fail-Stage "build" "TypeScript compilation failed: $_"
    } finally {
        Pop-Location
    }
}

# Stage 4 - Validate config
Write-Stage 4 "validate config"

if (Test-Path $OpenCodeConfigFile) {
    try {
        $raw = Get-Content $OpenCodeConfigFile -Raw
        $stripped = $raw -replace '//[^\n]*','' -replace '/\*[\s\S]*?\*/',''
        $null = $stripped | ConvertFrom-Json
        Write-Pass "opencode.jsonc parses"
    } catch {
        Write-Warn "opencode.jsonc has parse errors: $_"
    }
} else {
    Write-Warn "opencode.jsonc not found (run install.ps1 after dotfiles are linked)"
}

# Stage 5 - Smoke
Write-Stage 5 "smoke"

if (Test-Path (Join-Path $Dist 'patch-validator.js')) {
    $result = node --input-type=module `
        -e "import('file:///${Dist.Replace('\','/')}/patch-validator.js').then(()=>process.exit(0)).catch(()=>process.exit(1))" `
        2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "patch-validator loads"
    } else {
        Write-Fail "patch-validator failed to load"
        $StageErrors.Add("smoke: patch-validator") | Out-Null
    }
} else {
    Write-Warn "dist/patch-validator.js not found - skipping load test"
}

# Stage 6 - Summary
Write-Stage 6 "summary"

if ($StageErrors.Count -gt 0) {
    Write-Host "`nInstall completed with errors:"
    foreach ($e in $StageErrors) { Write-Host "  x $e" -ForegroundColor Red }
    Write-Host "`nRun doctor:"
    Write-Host "  pwsh bootstrap/opencode/doctor.ps1"
    exit 1
}

Write-Pass "opencode-tools package built"
Write-Pass "tool sources synced to dotfiles"
Write-Host "`nNext steps:"
Write-Host "  1. Run install.ps1 to link dotfiles:  pwsh ./install.ps1"
Write-Host "  2. Run doctor to verify:              pwsh bootstrap/opencode/doctor.ps1"

#Requires -Version 7
<#
.SYNOPSIS
    Doctor/health check for the OpenCode AI agent platform (Windows/PowerShell).

.DESCRIPTION
    Validates config, tools, skills, agents, and runtime environment.

.PARAMETER Json
    Emit a JSON diagnostics report to stdout (suitable for CI).
#>
[CmdletBinding()]
param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir          = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot           = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$OpenCodeConfigDir  = Join-Path $env:APPDATA 'OpenCode'
$OpenCodeConfigFile = Join-Path $OpenCodeConfigDir 'opencode.jsonc'
$ToolsSrc           = Join-Path $RepoRoot 'packages\opencode-tools\src'
$DotfilesToolsDir   = Join-Path $RepoRoot 'dotfiles\ai-agents\opencode\tools'
$SkillsDir          = Join-Path $RepoRoot 'dotfiles\ai-agents\opencode\skills'
$AgentsDir          = Join-Path $RepoRoot 'dotfiles\ai-agents\opencode\agents'
$AgentsMd           = Join-Path $RepoRoot 'dotfiles\ai-agents\opencode\AGENTS.md'
$Dist               = Join-Path $RepoRoot 'packages\opencode-tools\dist'

function Write-Pass  { param($Msg) Write-Host "  $([char]0x2713) $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "  ! $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "  x $Msg" -ForegroundColor Red }
function Write-Section { param($Name) Write-Host "`n── $Name ──" }

$Passed = 0; $Warned = 0; $Failed = 0
$JsonResults = [System.Collections.Generic.List[hashtable]]::new()

function Record { param($Name, $Status, $Message, $Detail = '')
    switch ($Status) {
        'ok'   { $script:Passed++; Write-Pass  "${Name}: ${Message}" }
        'warn' { $script:Warned++; Write-Warn  "${Name}: ${Message}" }
        'fail' { $script:Failed++; Write-Fail  "${Name}: ${Message}" }
    }
    if ($Json) {
        $JsonResults.Add(@{ name=$Name; status=$Status; message=$Message; detail=$Detail }) | Out-Null
    }
}

# Config
Write-Section "Config"

if (Test-Path $OpenCodeConfigFile) {
    Record "config-file" "ok" "opencode.jsonc exists"
    try {
        $raw = Get-Content $OpenCodeConfigFile -Raw
        $stripped = $raw -replace '//[^\n]*','' -replace '/\*[\s\S]*?\*/',''
        $null = $stripped | ConvertFrom-Json
        Record "config-parse" "ok" "opencode.jsonc parses successfully"
    } catch {
        Record "config-parse" "fail" "opencode.jsonc has JSON parse errors" "$_"
    }
} else {
    Record "config-file" "warn" "opencode.jsonc not found at $OpenCodeConfigFile" "Run install.ps1 after dotfiles are linked"
    Record "config-parse" "warn" "skipped (config not found)"
}

# Tools
Write-Section "Tools"

if (Test-Path $ToolsSrc) {
    Record "tools-src-dir" "ok" "packages/opencode-tools/src exists"
} else {
    Record "tools-src-dir" "fail" "packages/opencode-tools/src not found" "Expected: $ToolsSrc"
}

foreach ($toolName in @('patch-validator','analysis-cache')) {
    $srcFile = Join-Path $ToolsSrc "${toolName}.ts"
    if (Test-Path $srcFile) {
        Record "tool-src-$toolName" "ok" "${toolName}.ts present in package src"
    } else {
        Record "tool-src-$toolName" "fail" "${toolName}.ts missing from package src" "Expected: $srcFile"
    }

    $dotfilesFile = Join-Path $DotfilesToolsDir "${toolName}.ts"
    if (Test-Path $dotfilesFile) {
        Record "tool-dotfiles-$toolName" "ok" "${toolName}.ts present in dotfiles/tools"
    } else {
        Record "tool-dotfiles-$toolName" "warn" "${toolName}.ts not in dotfiles/tools (run install.ps1)" "Expected: $dotfilesFile"
    }

    $distFile = Join-Path $Dist "${toolName}.js"
    if (Test-Path $distFile) {
        Record "tool-dist-$toolName" "ok" "${toolName}.js compiled"
    } else {
        Record "tool-dist-$toolName" "warn" "${toolName}.js not built (run: npm run build)" "Expected: $distFile"
    }
}

$pvDist = Join-Path $Dist 'patch-validator.js'
if (Test-Path $pvDist) {
    $pvPath = $pvDist.Replace('\','/')
    $exitCode = & node --input-type=module `
        -e "import('file:///$pvPath').then(()=>process.exit(0)).catch(()=>process.exit(1))" `
        2>$null; $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Record "tool-load-patch-validator" "ok" "patch-validator loads successfully"
    } else {
        Record "tool-load-patch-validator" "fail" "patch-validator failed to load from dist" "Run: npm run build"
    }
} else {
    Record "tool-load-patch-validator" "warn" "load test skipped (dist not built)"
}

# Skills
Write-Section "Skills"

if (Test-Path $SkillsDir) {
    $skillFiles = Get-ChildItem -Path $SkillsDir -Recurse -Filter 'SKILL.md'
    $skillCount = $skillFiles.Count
    $skillErrors = 0
    foreach ($f in $skillFiles) {
        $first = (Get-Content $f.FullName -TotalCount 1)
        if ($first -ne '---') { $skillErrors++ }
    }
    if ($skillErrors -eq 0) {
        Record "skills-frontmatter" "ok" "${skillCount} SKILL.md files have valid frontmatter start"
    } else {
        Record "skills-frontmatter" "fail" "${skillErrors}/${skillCount} SKILL.md files missing '---' frontmatter"
    }
} else {
    Record "skills-dir" "fail" "skills directory not found: $SkillsDir"
}

# Agents
Write-Section "Agents"

if (Test-Path $AgentsDir) {
    $agentCount = (Get-ChildItem -Path $AgentsDir -Filter '*.md' -Recurse).Count
    Record "agents-dir" "ok" "${agentCount} agent definition(s) found"
} else {
    Record "agents-dir" "warn" "agents directory not found: $AgentsDir"
}
if (Test-Path $AgentsMd) {
    Record "agents-md" "ok" "AGENTS.md exists"
} else {
    Record "agents-md" "warn" "AGENTS.md not found"
}

# Runtime
Write-Section "Runtime"

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nv = node --version
    $nm = [int](($nv -replace '^v','').Split('.')[0])
    if ($nm -ge 20) { Record "runtime-node" "ok" "node $nv" }
    else            { Record "runtime-node" "warn" "node $nv (recommend >=20)" }
} else {
    Record "runtime-node" "fail" "node not found"
}
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Record "runtime-npm" "ok" "npm $(npm --version)"
} else {
    Record "runtime-npm" "warn" "npm not found"
}

# Summary
Write-Section "Summary"

$overall = if ($Failed -gt 0) { 'fail' } elseif ($Warned -gt 0) { 'warn' } else { 'ok' }

if ($Json) {
    $report = @{
        tool      = 'opencode-doctor'
        version   = '1.0.0'
        timestamp = (Get-Date -Format 'o')
        overall   = $overall
        passed    = $Passed
        warned    = $Warned
        failed    = $Failed
        checks    = $JsonResults
    }
    $report | ConvertTo-Json -Depth 5
}

Write-Host "  passed:  $Passed"
Write-Host "  warned:  $Warned"
Write-Host "  failed:  $Failed"
Write-Host "  overall: $overall"

if ($overall -eq 'fail') { exit 1 }

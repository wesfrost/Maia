<#  scripts/fresh_setup_v2.ps1
    Fresh setup with fixes + optional Copilot config for the Maia repo.

    Usage examples:
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -Clean -PatchRouter -SetupCopilot -Commit
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -RunTests
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -Configuration Release -Publish
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string]  $SolutionName   = "Maia",
  [switch]  $Clean,
  [switch]  $PatchRouter,
  [switch]  $SetupCopilot,
  [switch]  $RunTests,
  [switch]  $Publish,
  [ValidateSet('Debug','Release')]
  [string]  $Configuration  = 'Debug',
  [switch]  $Commit
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Info($m){ Write-Host "[INFO]    $m" -ForegroundColor Cyan }
function Write-Warn($m){ Write-Host "[WARN]    $m" -ForegroundColor Yellow }
function Write-Error2($m){ Write-Host "[ERROR]   $m" -ForegroundColor Red }
function Write-OK($m){ Write-Host "[SUCCESS] $m" -ForegroundColor Green }

function Require-Command([string]$name){
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command '$name' not found in PATH."
  }
}

if ($PSVersionTable.PSVersion.Major -lt 5) { throw "PowerShell 5.1+ required. Current: $($PSVersionTable.PSVersion)" }
Require-Command dotnet

$RepoRoot = if ($PSScriptRoot) { Resolve-Path (Join-Path $PSScriptRoot "..") } else { Resolve-Path "." }
Set-Location $RepoRoot
Write-Info "Repo root: $RepoRoot"

$SolutionPath = Join-Path $RepoRoot "$SolutionName.sln"
$RouterPath   = Join-Path $RepoRoot "packages\router-rules\Router.cs"

if ($Clean) {
  if ($PSCmdlet.ShouldProcess("bin/obj under $RepoRoot","Clean")) {
    Write-Info "Cleaning bin/obj directories"
    Get-ChildItem -Recurse -Directory -Include bin,obj -ErrorAction SilentlyContinue |
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  }
}

if ($PatchRouter) {
  $routerDir = Split-Path $RouterPath -Parent
  if (-not (Test-Path $routerDir)) { New-Item -ItemType Directory -Force -Path $routerDir | Out-Null }
  if (Test-Path $RouterPath) {
    $backup = "$RouterPath.bak_$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item $RouterPath $backup -Force
    Write-Info "Backed up Router.cs -> $backup"
  } else {
    Write-Warn "Router.cs not found; creating a minimal baseline."
  }

$routerContent = @"
namespace Maia.RouterRules;

public static class Router
{
    // Minimal, known-good prompt using raw string literal
    private const string SystemPrompt = """
You are Maia Router.
Decide which model/route id should handle the task.
Return only one of: fast, balanced, deep.
""";

    public static string Route(string task)
    {
        if (string.IsNullOrWhiteSpace(task))
            return "balanced";

        var len = task.Length;
        if (len < 120) return "fast";
        if (len < 800) return "balanced";
        return "deep";
    }
}
"@
  $routerContent | Out-File -FilePath $RouterPath -Encoding UTF8 -Force
  Write-OK "Patched Router.cs"
}

if (Test-Path $SolutionPath) {
  $bak = "$SolutionPath.bak_$(Get-Date -Format yyyyMMddHHmmss)"
  Copy-Item $SolutionPath $bak -Force
  Remove-Item $SolutionPath -Force
  Write-Info "Backed up and removed existing $SolutionName.sln"
}

Write-Info "Creating $SolutionName.sln"
dotnet new sln -n $SolutionName | Out-Null

$Projects = Get-ChildItem -Recurse -Filter *.csproj
if (-not $Projects -or $Projects.Count -eq 0) { throw "No .csproj files found under $RepoRoot" }
foreach ($p in $Projects) { dotnet sln $SolutionPath add $p.FullName | Out-Null }
Write-OK ("Added {0} projects to {1}" -f $Projects.Count, $SolutionPath)

function Find-Proj([string]$name) {
  $Projects | Where-Object { $_.Name -ieq "$name.csproj" } | Select-Object -First 1 | ForEach-Object { $_.FullName }
}
function Safe-AddRef($from,$to){
  if ($from -and $to) {
    Write-Info "Reference: $(Split-Path $from -Leaf) -> $(Split-Path $to -Leaf)"
    dotnet add $from reference $to | Out-Null
  }
}
$Contracts    = Find-Proj "Maia.Contracts"
$RouterRules  = Find-Proj "Maia.RouterRules"
$Memory       = Find-Proj "Maia.Memory"
$Orchestrator = Find-Proj "Maia.Orchestrator"

Safe-AddRef $RouterRules  $Contracts
Safe-AddRef $Memory       $Contracts
Safe-AddRef $Orchestrator $Contracts
Safe-AddRef $Orchestrator $RouterRules
Safe-AddRef $Orchestrator $Memory

Write-Info "dotnet restore"
dotnet restore $SolutionPath
Write-Info "dotnet build ($Configuration)"
dotnet build $SolutionPath -c $Configuration --nologo

if ($RunTests) {
  Write-Info "dotnet test ($Configuration)"
  dotnet test $SolutionPath -c $Configuration --nologo --no-build
}

if ($Publish) {
  $PublishTargets = @($Orchestrator) + ($Projects | Where-Object { $_.Name -notmatch "Contracts|Tests" -and $_ -ne $Orchestrator } | ForEach-Object { $_.FullName })
  $PubOut = Join-Path $RepoRoot "artifacts\publish\$Configuration"
  New-Item -ItemType Directory -Force -Path $PubOut | Out-Null
  foreach ($proj in $PublishTargets | Where-Object { $_ }) {
    Write-Info "Publishing: $(Split-Path $proj -LeafBase)"
    dotnet publish $proj -c $Configuration -o (Join-Path $PubOut (Split-Path $proj -LeafBase)) --nologo
  }
  Write-OK "Publish complete  $PubOut"
}

if ($SetupCopilot) {
  $GhDir     = Join-Path $RepoRoot ".github"
  $PromptDir = Join-Path $GhDir "copilot\prompts"
  $InstPath  = Join-Path $GhDir "copilot-instructions.md"

  New-Item -ItemType Directory -Force -Path $GhDir, (Split-Path $PromptDir -Parent), $PromptDir | Out-Null

$Instructions = @"
# Maia  Repository Custom Instructions for GitHub Copilot

## Purpose
You are assisting on the **Maia AI** platform (Orchestrated Automation Workspace) for Roam Ebooks.
Priorities:
1. High-accuracy reasoning & decision-making
2. Security-by-default (no secrets, least privilege, validated inputs)
3. Maintainable .NET 9 / raw strings; small, reviewable diffs
4. Strong tests and docs
"@
$RouterFixPrompt = @"
# Fix Router Build (Prompt)
- Convert multi-line strings to raw strings.
- Close quotes and end statements with `;` (avoid naked `@`).
- Add/extend unit tests; include *Security Notes* in PR.
"@
$FeatureSafePrompt = @"
# Add Feature Safely (Prompt)
- Validate inputs; no secrets; minimal deps.
- Unit tests (happy+edges); docs if behavior changes.
- Small diff + PR Security Notes.
"@
$ReviewPrompt = @"
# Code Review  Maia Policy (Prompt)
Check correctness, security-by-default, and maintainability.
Suggest concrete fixes with short code snippets.
"@

  $Instructions     | Out-File -Encoding UTF8 $InstPath -Force
  $RouterFixPrompt  | Out-File -Encoding UTF8 (Join-Path $PromptDir "router-fix.prompt.md") -Force
  $FeatureSafePrompt| Out-File -Encoding UTF8 (Join-Path $PromptDir "feature-safe.prompt.md") -Force
  $ReviewPrompt     | Out-File -Encoding UTF8 (Join-Path $PromptDir "review-maia-policy.prompt.md") -Force
  Write-OK "Copilot instructions & prompts written."
}

if ($Commit) {
  if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
      git add "$SolutionPath" 2>$null | Out-Null
      if ($PatchRouter)   { git add $RouterPath 2>$null | Out-Null }
      if ($SetupCopilot)  { git add .github 2>$null | Out-Null }
      git commit -m "chore(setup): fresh setup v2 (+ optional Router fix / Copilot / publish)" 2>$null | Out-Null
      Write-OK "Committed setup changes."
    } catch {
      Write-Warn "Git commit skipped or failed (repo not initialized or nothing to commit)."
    }
  } else {
    Write-Warn "Git not found; skipping commit."
  }
}

Write-Host ""
Write-OK "FRESH SETUP V2 COMPLETE"
Write-Info "Solution:      $SolutionPath"
Write-Info "Configuration: $Configuration"
Write-Info "PatchedRouter: $($PatchRouter.IsPresent)"
Write-Info "SetupCopilot:  $($SetupCopilot.IsPresent)"
Write-Info "RunTests:      $($RunTests.IsPresent)"
Write-Info "Publish:       $($Publish.IsPresent)"

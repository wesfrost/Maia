<#  scripts/fresh_setup_v2.ps1
    Fresh setup with fixes + optional Copilot config for the Maia repo.

    Features:
      - Optional deep clean of bin/obj
      - Optional Router.cs patch (fixes newline-in-constant)
      - Recreate solution, add all .csproj, wire typical references
      - Restore, build, optional test & publish
      - Optional GitHub Copilot repo instructions + prompts
      - Optional git commit
      - Idempotent, verbose, WhatIf-aware

    Usage examples:
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -Clean -PatchRouter -SetupCopilot -Commit
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -SolutionName Maia -RunTests -Verbose
      powershell -ExecutionPolicy Bypass -File .\scripts\fresh_setup_v2.ps1 -Publish -Configuration Release
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string]  $SolutionName   = "Maia",
  [switch]  $Clean,
  [switch]  $PatchRouter,
  [switch]  $SetupCopilot,
  [switch]  $RunTests,
  [switch]  $Publish,                        # dotnet publish for deployables (opt-in)
  [ValidateSet('Debug','Release')]
  [string]  $Configuration  = 'Debug',
  [switch]  $Commit
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ---------- Logging helpers ----------
function Write-Info($m)    { Write-Host "[INFO]    $m" -ForegroundColor Cyan }
function Write-Warn($m)    { Write-Host "[WARN]    $m" -ForegroundColor Yellow }
function Write-Error2($m)  { Write-Host "[ERROR]   $m" -ForegroundColor Red }
function Write-OK($m)      { Write-Host "[SUCCESS] $m" -ForegroundColor Green }

# ---------- Preconditions ----------
function Require-Command([string]$name){
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command '$name' not found in PATH."
  }
}

# PowerShell 5.1+ (Windows) and dotnet CLI required
if ($PSVersionTable.PSVersion.Major -lt 5) { throw "PowerShell 5.1+ required. Current: $($PSVersionTable.PSVersion)" }
Require-Command dotnet

# ---------- Repo root detection ----------
# If script is run directly: $PSScriptRoot points to scripts/
# If user pastes content: fallback to current location
$RepoRoot = if ($PSScriptRoot) { Resolve-Path (Join-Path $PSScriptRoot "..") } else { Resolve-Path "." }
Set-Location $RepoRoot
Write-Info "Repo root: $RepoRoot"

# ---------- Paths ----------
$SolutionPath = Join-Path $RepoRoot "$SolutionName.sln"
$RouterPath   = Join-Path $RepoRoot "packages\router-rules\Router.cs"

# ---------- Optional Clean ----------
if ($Clean) {
  if ($PSCmdlet.ShouldProcess("bin/obj under $RepoRoot","Clean")) {
    Write-Info "Cleaning bin/obj directories…"
    Get-ChildItem -Recurse -Directory -Include bin,obj -ErrorAction SilentlyContinue |
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# ---------- Patch Router (optional) ----------
if ($PatchRouter) {
  $routerDir = Split-Path $RouterPath -Parent
  if (-not (Test-Path $routerDir)) {
    if ($PSCmdlet.ShouldProcess($routerDir,"Create directory")) {
      New-Item -ItemType Directory -Force -Path $routerDir | Out-Null
    }
  }
  if (Test-Path $RouterPath) {
    $backup = "$RouterPath.bak_$(Get-Date -Format yyyyMMddHHmmss)"
    if ($PSCmdlet.ShouldProcess($RouterPath,"Backup to $backup")) {
      Copy-Item $RouterPath $backup -Force
      Write-Info "Backed up Router.cs -> $backup"
    }
  } else {
    Write-Warn "Router.cs not found; will create a minimal baseline."
  }

  $RouterContent = @'
namespace Maia.RouterRules;

public static class Router
{
    // Minimal, known-good prompt using raw string literal
    private const string SystemPrompt = """
You are Maia Router.
Decide which model/route id should handle the task.
Return only one of: fast, balanced, deep.
""";

    /// <summary>
    /// Simple placeholder router for compile sanity. Replace with real rules/LLM call later.
    /// </summary>
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
'@

  if ($PSCmdlet.ShouldProcess($RouterPath,"Write patched Router.cs")) {
    $RouterContent | Out-File -FilePath $RouterPath -Encoding UTF8 -Force
    Write-OK "Patched Router.cs with a safe, compiling implementation."
  }
}

# ---------- Recreate solution & add projects ----------
if (Test-Path $SolutionPath) {
  $bak = "$SolutionPath.bak_$(Get-Date -Format yyyyMMddHHmmss)"
  if ($PSCmdlet.ShouldProcess($SolutionPath,"Backup to $bak then remove")) {
    Copy-Item $SolutionPath $bak -Force
    Remove-Item $SolutionPath -Force
    Write-Info "Backed up and removed existing $SolutionName.sln"
  }
}

Write-Info "Creating $SolutionName.sln…"
dotnet new sln -n $SolutionName | Out-Null

$Projects = Get-ChildItem -Recurse -Filter *.csproj
if (-not $Projects -or $Projects.Count -eq 0) {
  throw "No .csproj files found under $RepoRoot"
}

foreach ($p in $Projects) {
  Write-Verbose "Adding project: $($p.FullName)"
  dotnet sln $SolutionPath add $p.FullName | Out-Null
}
Write-OK ("Added {0} projects to {1}" -f $Projects.Count, $SolutionPath)

# ---------- Wire references ----------
function Find-Proj([string]$name) {
  $Projects | Where-Object { $_.Name -ieq "$name.csproj" } | Select-Object -First 1 | ForEach-Object { $_.FullName }
}
function Safe-AddRef($from, $to) {
  if ($from -and $to) {
    Write-Info "Reference: $(Split-Path $from -Leaf) -> $(Split-Path $to -Leaf)"
    dotnet add $from reference $to | Out-Null
  } else {
    Write-Verbose "Skipping ref: from=[$from] to=[$to]"
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

# ---------- Restore & Build ----------
Write-Info "dotnet restore…"
dotnet restore $SolutionPath

Write-Info "dotnet build ($Configuration)…"
dotnet build $SolutionPath -c $Configuration --nologo

# ---------- Optional: Run tests ----------
if ($RunTests) {
  Write-Info "dotnet test ($Configuration)…"
  dotnet test $SolutionPath -c $Configuration --nologo --no-build
}

# ---------- Optional: Publish (targets deployable projects) ----------
if ($Publish) {
  # heuristic: publish any project that looks like an app (not Contracts)
  $PublishTargets = @($Orchestrator) + ($Projects | Where-Object { $_.Name -notmatch "Contracts|Tests|\.Contracts|\.Tests" -and $_ -ne $Orchestrator } | ForEach-Object { $_.FullName })
  $PubOut = Join-Path $RepoRoot "artifacts\publish\$Configuration"
  if ($PSCmdlet.ShouldProcess($PubOut,"Create/overwrite publish output")) {
    New-Item -ItemType Directory -Force -Path $PubOut | Out-Null
  }
  foreach ($proj in $PublishTargets | Where-Object { $_ }) {
    Write-Info "Publishing: $(Split-Path $proj -LeafBase)"
    dotnet publish $proj -c $Configuration -o (Join-Path $PubOut (Split-Path $proj -LeafBase)) --nologo
  }
  Write-OK "Publish complete → $PubOut"
}

# ---------- Optional: Setup GitHub Copilot repo instructions ----------
if ($SetupCopilot) {
  $GhDir        = Join-Path $RepoRoot ".github"
  $PromptDir    = Join-Path $GhDir "copilot\prompts"
  $InstPath     = Join-Path $GhDir "copilot-instructions.md"

  if ($PSCmdlet.ShouldProcess($GhDir,"Ensure .github structure")) {
    New-Item -ItemType Directory -Force -Path $GhDir       | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path $PromptDir -Parent) | Out-Null
    New-Item -ItemType Directory -Force -Path $PromptDir   | Out-Null
  }

  $Instructions = @'
# Maia – Repository Custom Instructions for GitHub Copilot

## Purpose
You are assisting on the **Maia AI** platform (Orchestrated Automation Workspace) for Roam Ebooks.
Priorities:
1. High-accuracy reasoning & decision-making
2. Security-by-default (no secrets, least privilege, validated inputs)
3. Maintainable .NET 9 / raw strings; small, reviewable diffs
4. Strong tests and docs

## Architecture
- `Maia.Contracts` (DTOs/interfaces only)
- `Ma

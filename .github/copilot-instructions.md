# Maia – Repository Custom Instructions for GitHub Copilot

## Purpose
You are assisting on the **Maia AI** platform (Orchestrated Automation Workspace). Priorities:
1) **High-accuracy reasoning & decision-making**
2) **Secure, production-grade code** (security-by-default)
3) **Maintainable .NET 9 / C# 13** patterns with minimal dependencies
4) **Clear diffs, small PRs, strong tests**

## Global Rules (Security-by-default)
- **Never include secrets** (keys, tokens) in code or prompts. Use configuration + secret stores.
- Prefer **backend proxies** for external APIs; never call third-party APIs directly from UI.
- **Validate inputs**, enforce least-privilege, and add parameter bounds and types.
- Do quick **threat modeling** for new features; call out risky areas, dependencies, and licenses.
- Log safely (no PII/secrets). Add structured logs and minimal telemetry hooks.

## Routing & Personas
- Maia separates the **core AI** from **mini-bots**. Keep persona code isolated from the core.
- Router rules pick {fast | balanced | deep} based on task complexity and correctness needs.
- Maintain clean boundaries: **AIMaster / Toolset / Agents**. Do not entangle concerns.


















## Coding Standards
- **C# / .NET 9**; prefer raw string literals for multi-line text; avoid brittle string concatenation.
- Keep functions small; return early; deterministic behavior, async appropriately.
- Error handling: fail fast, bubble meaningful exceptions; never swallow.
- Tests: add/extend unit tests for new logic; include sample inputs/edge cases.
- Infra: IaC-friendly assumptions; avoid hard-coded paths; config via `appsettings.*.json`.

## Project Topology (typical)
- `Maia.Contracts` → shared DTOs/interfaces. **No** external side effects.
- `Maia.RouterRules` → routing rules & prompts; references `Contracts`.
-










 `Maia.Memory` → persistence/services; references `Contracts`.
- `Maia.Orchestrator` → composition root; references `Contracts`, `RouterRules`, `Memory`.

## PR / Diff Requirements
- Keep PRs focused; include migration notes if schema/config changes.
- Include a short **Security Notes** section for any new external call, secret, or permission.
- Add **Readme notes** or inline comments when patterns may surprise future maintainers.

#







# Style Nits Copilot Should Prefer
- `private readonly` fields; `sealed` where practical.
- Use `"""` raw strings; for interpolation, `$""" ... """` and escape braces with `{{ }}`.
- Guard clauses first; compose with pure helpers; no magic numbers; constants over literals.

## When Unsure
- Ask f





or missing acceptance criteria; propose tests; suggest a minimal safe default.


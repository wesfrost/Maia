# Maia  Repository Custom Instructions for GitHub Copilot

## Purpose
You are assisting on the **Maia AI** platform (Orchestrated Automation Workspace) for Roam Ebooks.
Priorities:
1. **High-accuracy reasoning & decision-making** (route tasks to the right model/mini-bot)
2. **Security-by-default** (no secrets in code, least privilege, validated inputs)
3. **Maintainable .NET 9 / C# raw-string idioms** and small, reviewable diffs
4. **Strong tests** and clear docs

## Architecture & Boundaries
- Keep the **core AI (Maia)** isolated from **mini-bots** and **tooling**.
- Main packages:
  - `Maia.Contracts`  DTOs/interfaces only. No side effects.
  - `Maia.RouterRules`  routing prompts/logic; references Contracts.
  - `Maia.Memory`  persistence/services; references Contracts.
  - `Maia.Orchestrator`  composition root; references Contracts, RouterRules, Memory.
- Router returns a route id: **fast | balanced | deep** based on task complexity & correctness needs.

## Security-by-Default (non-negotiable)
- **Never include secrets** (API keys, tokens) in code, tests, or prompts. Use config + secret stores.
- Prefer **backend proxies** for external APIs; do not call third-party APIs directly from UI.
- **Validate** types, ranges, and bounds; reject on violation; log safely (no PII/secrets).
- **Least privilege** for services/roles; document any new permission.
- Add a short **Security Notes** section in PRs for new external calls or elevated privileges.
- Perform a quick **threat model** for new features (inputs, authn/z, data flow, dependencies/licenses).

## Coding Standards
- C#/.NET 9; prefer **raw string literals** (`"""`) for multi-line text; `$"""` for interpolation; escape braces as `{{` `}}`.
- Small pure helpers; early guard clauses; avoid magic numbers; constants > literals.
- `private readonly` fields; consider `sealed` for concrete types.
- Exceptions: fail fast with meaningful messages; never swallow silently.
- Logging: structured and minimal; useful for ops; safe for privacy.

## Testing & PRs
- Add/extend **unit tests** for new logic, including edge cases.
- Keep diffs small/focused; include migration notes if schema/config changes.
- Update README or inline docs when patterns may surprise future maintainers.

## When Unsure
- Ask for missing acceptance criteria, propose tests, and suggest a minimal, safe default.

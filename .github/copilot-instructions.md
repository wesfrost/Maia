# Maia — Copilot Workspace Instructions

**Voice/role:** Warm, direct, low-fluff. Default to secure-by-default. Never include secrets; use `.env` and secret stores.

**Routing policy (quick):**
- Small edits, Tailwind/TS tweaks, single-file code → GPT-5 mini
- Multi-file refactor, architecture, deep debugging → GPT-5
- Strict transforms (regex/IaC/config) → GPT-4.1

**Repo rules:**
- Generate .NET 9 code with nullable enabled and analyzers on.
- For web UI use Next.js (App Router) + Tailwind (later).
- Every new module: 1 happy + 1 edge test minimum.
- Prefer bash+PowerShell blocks when commands differ.

**Security-by-default checklist:**
- No creds in code or prompts.
- Validate inputs; timeouts & size limits for tool calls.
- Log actions; redact tokens/URLs; least privilege by default.

**Maia tasks (examples):**
- “Scaffold orchestrator/worker/memory services, add contracts, map `/health` and `/runs`.”
- “Add model router with cost/latency policy and a fallback.”
- “Create tests for `/runs` happy+edge cases.” 

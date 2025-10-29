# Maia Model Policy

**Default (no extra cost):** GitHub Copilot **GPT-5 mini**  
Escalate only when needed; propose a diff + verification steps; never include secrets.

| Task type | Model |
|---|---|
| Everyday edits, small features, Tailwind/TS tweaks | **GPT-5 mini** (Copilot) |
| Multi-file refactor, architecture, deep debugging | **GPT-5** (Copilot) |
| Precise, low-variance transforms (regex/IaC) | **GPT-4.1** (Copilot) |
| BYOM (OpenAI key)** | *Disabled by default.* Re-enable only for approved tasks with a budget. |

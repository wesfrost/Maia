# RoamOS Monorepo (WIP)

Starter scaffold for Wes's orchestration workspace: personas, agents, web, and infra.

## Quick start
1. Open in **VS Code** at the repo root.
2. Install the **Dev Containers** extension (ms-vscode-remote.remote-containers).
3. Press **F1** → “Dev Containers: Reopen in Container”.
4. On first start, `.devcontainer/post-create.sh` runs to restore deps if present.

## Structure
```text
.
├─ .devcontainer/           # Reproducible dev environment
├─ .vscode/                 # Editor settings & recommended extensions
├─ apps/                    # Executable apps (web, api, cli, workers)
├─ packages/                # Shared libs (tooling, prompts, schemas)
├─ services/                # Long‑running services / microservices
├─ infra/                   # IaC, pipelines, security baselines
├─ scripts/                 # DX scripts (format, lint, local run)
├─ tests/                   # Test suites
├─ docs/                    # Architecture notes, ADRs
├─ .github/workflows/       # CI stubs
├─ .env.template            # Copy to .env (never commit real secrets)
├─ .editorconfig            # Consistent formatting
├─ .gitattributes           # Normalize line endings
├─ .gitignore               # Ignore build artifacts & secrets
└─ LICENSE                  # Choose a license
```

## Security-by-default
- **No secrets** in source. Use `.env` locally and secret stores in CI/CD.
- Principle of least privilege for cloud roles.
- Pre-commit hooks recommended (add later in `scripts/`).

---
Author: Maia

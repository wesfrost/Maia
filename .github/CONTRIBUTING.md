# Contributing

## Getting started
- Open in **VS Code**. If possible: `F1 → Dev Containers: Reopen in Container`.
- Otherwise use **WSL** (Ubuntu) with Node LTS, Python 3.11, and .NET 9.

## Branching & commits
- Branch: `feat/<short>`, `fix/<short>`, `docs/<short>`, etc.
- Commits: **Conventional Commits** (examples: `feat(web): add hero`, `fix(worker): handle null ids`).

## PR checklist
- [ ] Lints/tests pass locally.
- [ ] No plaintext secrets in code, config, or CI.
- [ ] Added/updated minimal tests (happy + edge).
- [ ] Included brief **Risk Notes** for auth/network/file-I/O changes.

## Running things
- Web (if present): `npm --prefix apps/web run dev`
- Worker (if present): `dotnet run --project services/worker`


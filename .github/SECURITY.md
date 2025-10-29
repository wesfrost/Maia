# Security Policy

- Please report vulnerabilities privately to the repo owner.
- Do not commit secrets. Use `.env` locally and secret managers in CI/CD.
- Use least-privilege IAM for cloud roles. Avoid wildcard `*` permissions.
- Keep dependencies updated; prefer well-maintained libraries.
- Add a brief threat note in PRs for new surfaces (auth, network, file I/O).

Supported versions: `main` branch.


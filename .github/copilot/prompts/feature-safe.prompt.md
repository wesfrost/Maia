# Add Feature Safely (Prompt)

**Goal**: Implement a small feature with security-by-default.
**Checklist**:
- Validate inputs and bounds; explicit types and null-handling.
- No secrets in code; config via `appsettings.{Environment}.json`.
- Minimal external deps; review licenses.
- Unit tests for happy path + edge cases; update docs/README if behavior changes.
- Small, reviewable diff; add Security Notes.

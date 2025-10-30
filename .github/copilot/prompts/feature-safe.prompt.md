# Add Feature Safely (Prompt)

**Checklist**:
- Validate inputs (types, ranges, null handling).
- No secrets in code/tests; config via `appsettings.{Environment}.json`.
- Minimal external deps; review licenses.
- Unit tests: happy path + edge cases; update docs as needed.
- Small, reviewable diff with a *Security Notes* section.

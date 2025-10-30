# Fix Router Build (Prompt)

**Goal**: Ensure `Maia.RouterRules` compiles and tests pass.
**Context**:
- Use C# raw string literals for multi-line prompts (avoid newline-in-constant).
- Close quotes and end statements with `;`. Avoid naked `@`.
**Tasks**:
1. Inspect `packages/router-rules/Router.cs` for unterminated or invalid strings.
2. Convert to `"""` raw strings (or `$"""` for interpolation).
3. Add/extend unit tests for routing heuristics; include edge cases.
4. Add a brief *Security Notes* section to the PR (no secrets in prompts, input validation).

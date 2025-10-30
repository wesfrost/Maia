# Fix Router Build (Prompt)

**Goal**: Ensure `Maia.RouterRules` compiles and passes tests.
**Context**:
- Use raw string literals for multi-line prompts.
- No naked `@` strings; close quotes; add a trailing semicolon.
**Tasks**:
1. Inspect `packages/router-rules/Router.cs` for unterminated strings or bad verbatim literals.
2. Replace with `"""` raw string literals where needed.
3. Add/extend unit tests for routing heuristics.
4. Suggest security notes (no secrets in prompts, no user-controlled injection points).

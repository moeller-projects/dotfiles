# Testability Design

Good:
- Constructor injection
- No static global state
- Pure functions
- Deterministic behavior

Bad:
- Hard-coded time
- Hard-coded randomness
- Direct DB calls in logic
- Hidden side effects

Rule:
Business logic must be testable without network/database.
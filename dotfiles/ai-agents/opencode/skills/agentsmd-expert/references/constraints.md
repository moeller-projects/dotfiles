# Constraints

## Safety

- Call out destructive commands explicitly.
- Note any directories that must not be modified.
- Specify when elevated permissions are required.

## Idempotency

- Prefer commands that do not mutate state by default.
- Mention `-DryRun` or `-Check` modes when available.

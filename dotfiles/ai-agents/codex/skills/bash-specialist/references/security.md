# Security

## Input Validation

- Validate required inputs and reject unexpected values.
- Use allow-lists where possible.

## Secrets Handling

- Prefer environment variables or secret stores.
- Never log secrets or store them in plain text.

## Safe Execution

- Avoid `eval` unless inputs are trusted.
- Quote arguments passed to external tools.
- Run with least privilege and avoid unnecessary elevation.

## Logging

- Log context, not sensitive values.
- Provide enough detail to debug without leaking secrets.

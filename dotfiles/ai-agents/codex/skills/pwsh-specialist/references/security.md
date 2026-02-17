# Security

## Input Validation

- Use validation attributes for simple cases.
- Add explicit checks for cross-field constraints.
- Reject unexpected input early with clear errors.

## Secrets Handling

- Prefer environment variables or secure stores.
- Use `Get-Credential` or `SecureString` for prompts.
- Never log secrets or store them in plain text.

## Safe Execution

- Avoid `Invoke-Expression` unless inputs are trusted.
- Escape or quote arguments passed to external tools.
- Run with least privilege and avoid unnecessary elevation.

## Logging

- Log context, not sensitive values.
- Provide enough detail to debug without leaking secrets.

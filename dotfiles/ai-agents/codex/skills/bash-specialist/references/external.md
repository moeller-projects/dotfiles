# External Commands

## Execution

- Check exit codes immediately (`if ! cmd; then ...; fi`).
- Prefer explicit command paths when required by environment.

## Safety

- Quote arguments, especially user input.
- Avoid `eval` unless inputs are trusted and strictly controlled.

## Example

```bash
if ! git status --porcelain >/dev/null; then
  printf "git status failed\n" >&2
  exit 1
fi
```

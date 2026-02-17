# Error Handling

## Defaults

- Use `set -euo pipefail` in new scripts.
- Set a useful `IFS` when reading input lines.

## Structured Handling

- Use `trap` for cleanup and error reporting.
- Return non-zero on failure and emit actionable messages.

## Example

```bash
set -euo pipefail

cleanup() {
  rm -f "$tmpfile"
}
trap cleanup EXIT
```

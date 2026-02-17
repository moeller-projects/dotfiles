# Sourcing

## Patterns

- Use `source` or `.` to load shared functions.
- Guard against double-loading with a sentinel variable.
- Keep sourced files side-effect free.

## Example

```bash
if [ -z "${_LIB_LOADED:-}" ]; then
  _LIB_LOADED=1
  source "$(dirname "$0")/lib.sh"
fi
```

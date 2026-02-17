# Idempotency

## Patterns

- Check current state before changing it.
- Use temporary files and atomic moves (`mv`) when writing outputs.
- Avoid destructive operations unless explicitly requested.

## Example

```bash
if [ ! -d "$dir" ]; then
  mkdir -p "$dir"
fi
```

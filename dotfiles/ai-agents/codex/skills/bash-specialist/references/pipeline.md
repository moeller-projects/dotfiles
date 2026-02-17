# Pipelines

## Guidance

- Stream data through pipelines instead of materializing large lists.
- Use `xargs -0` with `find -print0` for robust file handling.
- Avoid useless `cat` when a tool can read files directly.

## Example

```bash
find . -type f -name '*.log' -print0 | xargs -0 rg -n 'ERROR'
```

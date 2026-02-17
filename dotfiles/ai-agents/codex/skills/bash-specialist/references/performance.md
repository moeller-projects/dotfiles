# Performance

## Collection Handling

- Avoid command substitution in tight loops.
- Prefer `while read -r` over `for` with command substitution for large inputs.
- Use `find` + predicates instead of enumerating everything.

## I/O Efficiency

- Cache expensive lookups.
- Minimize repeated filesystem and network calls.

## Profiling

- Use `time` for quick checks.
- Add timing logs around hotspots when needed.

## Example

```bash
while IFS= read -r line; do
  printf "%s\n" "$line"
done < "$file"
```

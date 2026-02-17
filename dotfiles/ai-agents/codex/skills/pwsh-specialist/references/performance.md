# Performance

## Collection Handling

- Avoid `+=` on arrays in large loops.
- Use `System.Collections.Generic.List[T]` for accumulation.
- Stream with pipelines instead of materializing large collections.

## I/O Efficiency

- Cache expensive lookups.
- Minimize repeated filesystem and network calls.
- Prefer targeted filters over broad enumeration.

## Profiling

- Use `Measure-Command` for quick checks.
- Add timing logs for hotspots when needed.

## Example

```powershell
$list = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -File -Path $Path | ForEach-Object {
    $list.Add($_.FullName)
}
```

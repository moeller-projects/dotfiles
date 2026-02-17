# Error Handling

## Defaults

- Prefer `$ErrorActionPreference = 'Stop'` when correctness matters.
- Use `-ErrorAction Stop` for specific calls.

## Structured Handling

- Wrap risky operations in `try { } catch { }`.
- Emit actionable errors with context, not raw exceptions alone.
- Use `throw` for terminating failures.

## External Commands

- Check `$LASTEXITCODE` after CLI calls.
- Treat non-zero exit codes as failures unless explicitly tolerated.

## Example

```powershell
$ErrorActionPreference = 'Stop'
try {
    $result = Invoke-RestMethod -Uri $Uri -Method Get -ErrorAction Stop
} catch {
    throw "Request failed for $Uri. $($_.Exception.Message)"
}
```

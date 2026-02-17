# External Commands

## Execution

- Use the call operator `&` to run executables.
- Capture exit codes via `$LASTEXITCODE`.
- Prefer `Start-Process -Wait -PassThru` for long-running tools.

## Safety

- Avoid `Invoke-Expression` unless inputs are trusted.
- Quote or escape arguments explicitly.

## Example

```powershell
& git status --porcelain
if ($LASTEXITCODE -ne 0) {
    throw "git status failed with $LASTEXITCODE"
}
```

# Idempotency

## Patterns

- Check current state before modifying it.
- Support `-WhatIf` and `-Confirm` with `SupportsShouldProcess`.
- Avoid destructive operations unless explicitly requested.

## Example

```powershell
[CmdletBinding(SupportsShouldProcess)]
param([string]$Path)

if (-not (Test-Path $Path)) {
    if ($PSCmdlet.ShouldProcess($Path, 'Create directory')) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}
```

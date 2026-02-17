# Pipelines

## Guidance

- Output objects, not formatted text.
- Use `ValueFromPipelineByPropertyName` to accept structured input.
- Keep pipeline stages small and composable.
- Avoid using `Format-*` in scripts producing data.

## Example

```powershell
function Get-Thing {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    process {
        [pscustomobject]@{ Name = $Name; Status = 'Ok' }
    }
}
```

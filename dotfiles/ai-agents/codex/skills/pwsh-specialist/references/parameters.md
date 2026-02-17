# Parameters and Cmdlets

## Patterns

- Use `[CmdletBinding()]` for advanced functions.
- Define parameters with explicit types.
- Prefer parameter sets when arguments are mutually exclusive.
- Support pipeline input only when it improves usability.

## Validation

- `ValidateSet` for small enumerations.
- `ValidatePattern` for structured strings.
- `ValidateRange` for numeric ranges.
- Use explicit checks for multi-field invariants.

## Common Attributes

- `Mandatory` for required inputs.
- `ValueFromPipeline` and `ValueFromPipelineByPropertyName` for pipeline support.
- `Alias` only when it improves discoverability.

## Example

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Start','Stop')]
    [string]$Action,

    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$Name
)
```

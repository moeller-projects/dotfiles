# Modules

## Structure

- Use a module folder with a `.psd1` manifest and `.psm1` implementation.
- Export only intended functions with `Export-ModuleMember`.
- Keep public API surface small and stable.

## Example

```powershell
# In module.psm1
function Invoke-Thing { }
Export-ModuleMember -Function Invoke-Thing
```

# Minimal Mutation Policy (STRICT)

## Output Contract

- Output MUST be a unified diff.
- NEVER rewrite entire files unless explicitly authorized.
- NEVER output full file contents.
- NEVER modify unrelated code.

## Mutation Budget

- Max files changed: 5
- Max total lines changed: 50
- Max per file: 30
- If >30% of a file changes → ABORT and explain.

## Forbidden Changes

- Formatting-only changes
- Import reordering unless required
- Whitespace-only diffs
- Mass renaming unless explicitly requested

## Required Metadata Block

Before the diff, output:

```json
{
  "files_changed": 1,
  "lines_added": 1,
  "lines_removed": 0,
  "mutation_ratio_estimate": "low"
}
```

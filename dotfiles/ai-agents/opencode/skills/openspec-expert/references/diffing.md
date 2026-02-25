# Spec Diffing and Versioning

Use diffing to make changes reviewable and traceable.

## Workflow

1. Identify the previous spec version or baseline.
2. Generate the updated spec using the standard scripts.
3. Produce a diff against the previous version (git diff or tool-native diff).
4. Summarize changes by section (inputs, outputs, constraints, acceptance criteria).
5. Note any version bump or compatibility impact.

## Diff Review Checklist

- All requirement changes are explicitly captured.
- No accidental deletions of constraints or acceptance criteria.
- Newly introduced risks or dependencies are documented.
- Version note is updated when behavior changes.

## Semantic Change Detection

The diff engine detects:

- Added FR/AC IDs
- Removed FR/AC IDs
- Modified FR/AC IDs
- Semantic change signals (text changes beyond ID changes)

Even if IDs remain unchanged, semantic_change_detected = true
indicates potential behavioral impact and must be reviewed.
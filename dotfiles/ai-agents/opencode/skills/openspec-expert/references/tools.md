# OpenSpec Expert Tools

Use only necessary tools and prefer repo-native workflows.

- Use the provided scripts under `scripts/` for spec generation.
- Validate before making large changes.
- Record CI/policy gate results in the output summary.
- Prefer deterministic and idempotent steps.
- Use git diff (or tool-native diff) for change review.

## CI Enforcement

In CI pipelines, use ONLY:

scripts/ci_gate.sh <spec> [base_ref]

Do not orchestrate validate/score/diff scripts individually in CI.
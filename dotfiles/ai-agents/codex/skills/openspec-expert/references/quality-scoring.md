# Quality Scoring

Specs must score at least 80/100 to pass.

## Scoring Rubric (100 total)

- Requirements coverage (0-25)
  - All requirements mapped to explicit spec sections
  - No ambiguous or missing requirements
- Acceptance criteria and testability (0-20)
  - Clear, measurable acceptance criteria
  - Tests or validation steps are feasible
- Constraints and risks (0-20)
  - Constraints documented with rationale
  - Risks and mitigations captured
- Clarity and structure (0-20)
  - Consistent structure and terminology
  - Inputs/outputs are unambiguous
- Validation readiness (0-15)
  - CI/policy gates described
  - Validation steps are deterministic

## Remediation Guidance

- If score < 80, identify the lowest-scoring categories first.
- Update the spec, re-run validation, and rescore.
- Record the final score and any remaining risks.

### Additional Enforcement Signals

The scoring engine also evaluates:

- Duplicate FR/AC identifiers (penalized)
- AC count relative to FR count (traceability heuristic)
- Presence of measurable constraints (latency, %, SLO, etc.)
- Vague language penalties

Remediation hints are emitted deterministically.
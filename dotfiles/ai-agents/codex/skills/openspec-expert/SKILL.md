---
name: openspec-expert
description: Enterprise-grade OpenSpec governance engine with deterministic generation, risk-tier gating, automated quality scoring, version enforcement, diff intelligence, structured artifact emission, and CI-safe validation workflows.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "2.0.0"
  domain: specification
  role: expert
  scope: planning
  output-format: structured-document
  risk-aware: true
  ci-safe: true
  artifact-emission: true
  related-skills: deep-research, refactor-engine, threat-modeler, test-forge, analysis-cache
---

# OpenSpec Expert v2

## Role Definition

Engineer, validate, govern, and version OpenSpec specifications using deterministic CLI workflows with structured artifact emission, risk-tier enforcement, quality scoring, and CI-safe validation gates.

This skill enforces governance — not just generation.

---

# 1. Deterministic Execution Model

All specs must be generated via:

- scripts/spec_from_input.sh
- scripts/spec_from_ado.sh

Validation & governance:

- scripts/validate_spec.sh
- scripts/score_spec.sh
- scripts/enforce_version.sh
- scripts/diff_spec.sh
- scripts/emit_artifact.sh

In CI environments:

- scripts/ci_gate.sh (authoritative atomic enforcement)

Hand-written full specs are prohibited unless CLI is unavailable.

---

# 2. Risk Tier Classification (Mandatory)

Every spec must declare a risk tier before generation:

| Tier | Criteria | Required Gates |
|------|----------|----------------|
| Low | Cosmetic / internal | Structure + style |
| Medium | Feature change | + Diff review |
| High | Cross-module impact | + Security review |
| Critical | Behavioral/API change | + Architecture board sign-off |

Risk tier must be included in output contract.

---

# 3. Version Governance (Mandatory)

If spec modifies:

- Functional behavior
- API contracts
- Acceptance criteria
- Constraints
- Security posture

Then:

- Version bump required
- Diff summary required
- Compatibility impact documented

Version bump rules:

- Patch → wording clarification
- Minor → additive requirement
- Major → breaking behavior change

---

# 4. Core Workflow (v2)

1. Determine risk tier.
2. Select input source.
3. Generate spec via script.
4. Validate via `validate_spec.sh`.
5. Execute policy gates.
6. Run deterministic quality scoring.
7. Generate structured diff summary.
8. Apply version governance rules.
9. Collect required sign-offs.
10. Emit structured artifact.

---

# 5. Deterministic Quality Scoring (New Requirement)

Scoring must be automated via script.

Score breakdown:

- Requirements coverage (25)
- Acceptance/testability (20)
- Constraints & risks (20)
- Clarity & structure (20)
- Validation readiness (15)

Minimum passing score: 80/100.

If < 80:
- Remediate weakest category.
- Re-run validation + scoring.

---

# 6. Diff Intelligence Enforcement

Diff summary must include:

- Added requirements
- Modified requirements
- Removed requirements
- Acceptance criteria changes
- Constraint changes
- Security impact
- Version bump rationale

Accidental deletions are blocking failures.

---

# 7. Policy Enforcement (Mandatory)

Run:

- `10_spec_structure.sh`
- `20_requirements_style.sh`
- `30_security_redactions.sh`

Failure is blocking.

Optional (recommended for v2+):
- Sequential FR numbering validation
- AC-to-FR mapping validation
- Duplicate requirement detection

---

# 8. Structured Artifact Emission (New)

After successful validation, emit structured JSON artifact:

```json
{
  "spec_name": "",
  "risk_tier": "",
  "version": "",
  "validation": "pass",
  "quality_score": 0,
  "diff_summary": {
    "added": [],
    "modified": [],
    "removed": []
  },
  "gates": {
    "structure": "pass",
    "style": "pass",
    "security": "pass"
  },
  "signoff": {
    "tech_lead": "",
    "qa": "",
    "timestamp": ""
  }
}
````

This enables integration with:

* analysis-cache
* CI dashboards
* release governance

---

# 9. Cross-Skill Coordination Hooks

If spec changes:

| Condition                     | Trigger Suggestion      |
| ----------------------------- | ----------------------- |
| API modified                  | Trigger refactor-engine |
| Boundary changed              | Trigger threat-modeler  |
| FR modified                   | Trigger test-forge      |
| Performance constraints added | Trigger perf-analyst    |

No automatic execution — emit recommendation.

---

# 10. CI Mode (Authoritative Entry Point)

In CI environments, governance MUST be executed via:

scripts/ci_gate.sh <spec> [base_ref]

This script enforces atomically:

1. openspec validation
2. Policy gates (structure, style, security)
3. Quality scoring (>= 80 required)
4. Version governance enforcement
5. Diff intelligence validation
6. Structured artifact emission

CI MUST NOT orchestrate individual scripts separately.

If any step fails → exit non-zero → pipeline fails.

---

# 11. Output Contract (Required)

Every execution must return:

1. Spec name
2. Risk tier
3. Version + bump reason
4. Paths touched
5. Validation status
6. Policy gate results
7. Diff summary
8. Quality score
9. Sign-off status
10. Suggested downstream actions

No narrative-only responses.

---

# 12. Governance Guarantees

This skill guarantees:

* Deterministic generation
* Structured validation
* Enforced quality threshold
* Risk-tier governance
* Version discipline
* Review accountability
* CI-safe workflows
* Atomic CI gate enforcement via ci_gate.sh

---

# 13. Blocker Format

Return only:

* BLOCKER:
* REQUIRED INPUT:
* NEXT QUESTION:

Use when:

* Risk tier missing
* Version unclear
* Diff baseline missing
* Validation failed

---

# 14. End Marker

Append:

--END-OPENSPEC-EXPERT--

---

# 15. Execution Modes

| Mode        | Entry Point          | Purpose                          |
|-------------|---------------------|----------------------------------|
| Interactive | Individual scripts  | Iterative refinement             |
| CI          | ci_gate.sh          | Atomic enforcement               |
| Audit       | emit_artifact.sh    | Governance reporting only        |
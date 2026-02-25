---
name: openspec-expert
description: Enterprise-grade OpenSpec governance engine with deterministic generation, risk-tier gating, automated quality scoring, version enforcement, diff intelligence, structured artifact emission, and CI-safe validation workflows.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "2.1.0"
  domain: specification
  role: expert
  scope: planning
  output-format: structured-document
  risk-aware: true
  ci-safe: true
  artifact-emission: true
  related-skills: deep-research, refactor-engine, threat-modeler, test-forge, analysis-cache
---

# OpenSpec Expert v2.1

## Role Definition

Engineer, validate, govern, and version OpenSpec specifications using deterministic CLI workflows with structured artifact emission, risk-tier enforcement, quality scoring, diff intelligence, and atomic CI validation.

This skill enforces governance — not just generation.

---

# 1. Deterministic Execution Model

All specs must be generated via:

- `scripts/spec_from_input.sh`
- `scripts/spec_from_ado.sh`

Validation & governance:

- `scripts/validate_spec.sh`
- `scripts/score_spec.sh`
- `scripts/enforce_version.sh`
- `scripts/diff_spec.sh`
- `scripts/emit_artifact.sh`

In CI environments:

- `scripts/ci_gate.sh` (authoritative atomic enforcement)

Hand-written full specs are prohibited unless CLI is unavailable.

---

# 2. Risk Tier Classification (Mandatory)

Every spec must declare a risk tier within the first 40 lines:

```

Version: x.y.z
Risk Tier: Low|Medium|High|Critical

```

### Risk Tiers

| Tier      | Criteria                     | Required Governance Expectations |
|-----------|-----------------------------|-----------------------------------|
| Low       | Cosmetic / internal         | Structure + style gates           |
| Medium    | Feature change              | + Diff review                     |
| High      | Cross-module impact         | + Security review recommended     |
| Critical  | Behavioral/API change       | + Architecture review required    |

Risk tier must be included in artifact output.

---

# 3. Version Governance (Mandatory)

If a spec modifies:

- Functional requirements (FR)
- Acceptance criteria (AC)
- API contracts
- Constraints (NFR)
- Security posture

Then:

- Semantic version bump required
- Diff summary required
- Compatibility impact must be reviewed

### Version Rules

- Patch → wording clarification only
- Minor → additive requirement
- Major → breaking behavior change

Failure to bump version when FR/AC change is blocking.

---

# 4. Core Workflow

1. Determine risk tier.
2. Select input source.
3. Generate spec via script.
4. Validate via `validate_spec.sh` (includes policy gates).
5. Run deterministic quality scoring.
6. Generate structured diff summary.
7. Enforce version governance.
8. Emit structured artifact.
9. Collect required human sign-offs (not enforced by script; tracked in artifact.json).

---

# 5. Deterministic Quality Scoring

Scoring is fully automated via `score_spec.sh`.

### Weighted Categories (100 total)

- Requirements coverage (25)
- Acceptance/testability (20)
- Constraints & risks (20)
- Clarity & structure (20)
- Validation readiness (15)

Minimum passing score: **80/100**

### Additional Deterministic Signals

The scoring engine evaluates:

- Duplicate FR IDs (penalized)
- Duplicate AC IDs (penalized)
- AC count relative to FR count (traceability heuristic)
- Presence of measurable constraints (latency, %, SLO, etc.)
- Vague language penalties
- Non-empty Open Questions section

Remediation hints are emitted deterministically.

---

# 6. Diff Intelligence Enforcement

Diff summary includes:

- Added FR/AC IDs
- Removed FR/AC IDs
- Modified FR/AC IDs
- Semantic change detection (text changes beyond ID changes)

`semantic_change_detected = true` requires explicit review even if IDs remain unchanged.

Accidental deletions are blocking failures.

---

# 7. Policy Enforcement (Mandatory)

The following policies are executed by `validate_spec.sh`:

- `10_spec_structure.sh`
- `20_requirements_style.sh`
- `30_security_redactions.sh`

Each gate produces structured results in `gates.json`.

Failure of any gate is blocking.

---

# 8. Structured Artifact Emission

After validation, `emit_artifact.sh` produces `artifact.json`:

```json
{
  "spec_name": "",
  "spec_file": "",
  "risk_tier": "",
  "version": "",
  "validation": "pass|fail",
  "gates": {
    "structure": "pass|fail",
    "style": "pass|fail",
    "security": "pass|fail",
    "version_governance": "pass|fail"
  },
  "quality": {
    "score": 0,
    "passing": true,
    "breakdown": {},
    "signals": {},
    "remediation_hints": []
  },
  "diff": {
    "available": true,
    "semantic_change_detected": false,
    "summary": {}
  },
  "signoff": {
    "tech_lead": "",
    "qa": "",
    "timestamp": ""
  },
  "downstream_recommendations": []
}
```

Artifacts enable integration with:

* CI dashboards
* Release governance
* analysis-cache
* audit trails

---

# 9. Cross-Skill Coordination Hooks

Based on diff + risk tier:

| Condition                     | Suggested Trigger |
| ----------------------------- | ----------------- |
| API modified                  | refactor-engine   |
| Boundary changed              | threat-modeler    |
| FR modified                   | test-forge        |
| High/Critical risk tier       | threat-modeler    |
| Performance constraints added | perf-analyst      |

No automatic execution — only structured recommendations.

---

# 10. CI Mode (Authoritative Entry Point)

In CI environments, governance MUST be executed via:

```
scripts/ci_gate.sh <spec> [base_ref]
```

This script enforces atomically:

1. OpenSpec validation
2. Policy gates
3. Quality scoring (>= 80 required)
4. Version governance enforcement
5. Diff intelligence validation
6. Structured artifact emission

CI MUST NOT orchestrate individual scripts separately.

If any step fails → non-zero exit → pipeline fails.

---

# 11. Output Contract (Required)

Every execution must return structured artifact data including:

1. Spec name
2. Spec file path
3. Risk tier
4. Version
5. Validation status
6. Policy gate results
7. Diff summary
8. Quality score and signals
9. Sign-off placeholders
10. Downstream recommendations

Narrative-only responses are prohibited.

---

# 12. Governance Guarantees

This skill guarantees:

* Deterministic generation
* Structured validation
* Enforced quality threshold
* Version discipline
* Risk-tier governance
* Diff traceability
* Structured audit artifacts
* Atomic CI enforcement via `ci_gate.sh`

---

# 13. Blocker Format

When required input is missing, return only:

```
BLOCKER:
REQUIRED INPUT:
NEXT QUESTION:
```

Used when:

* Risk tier missing
* Version unclear
* Diff baseline missing
* Validation failed

---

# 14. End Marker

Append:

```
--END-OPENSPEC-EXPERT--
```

---

# 15. Execution Modes

| Mode        | Entry Point        | Purpose                       |
| ----------- | ------------------ | ----------------------------- |
| Interactive | Individual scripts | Iterative refinement          |
| CI          | ci_gate.sh         | Atomic governance enforcement |
| Audit       | emit_artifact.sh   | Reporting without blocking CI |
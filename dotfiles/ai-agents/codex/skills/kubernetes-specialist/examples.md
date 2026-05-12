# Examples

## 1. Primary Scenario

**Request**
Review this Deployment and Service for production readiness.

**Good Response Shape**

```markdown
Task
- Restate the requested outcome.

Observed
- Cite the inputs or constraints that are actually available.

Deliverable
- Produce the requested Kubernetes change or diagnosis.

Validation
- List the smallest set of checks needed to confirm the result.

Risks
- Note the main failure mode or scope caveat.
```

---

## 2. Review or Triage Scenario

**Request**
Diagnose why this pod never becomes Ready.

**Good Response Shape**

```markdown
Task
- Identify what is being reviewed.

Observed
- Call out the strongest evidence first.

Findings
- Separate confirmed issues from inferred risks.

Recommendation
- Propose the smallest high-value next step.

Validation
- State what should be checked next.
```

---

## 3. Blocker or No-Change Scenario

**Request**
Fix the cluster, but there is no manifest, event log, or environment context.

**Good Response Shape**

```markdown
Decision
- BLOCKER or NO CHANGE

Reason
- Explain whether the issue is missing input or unnecessary churn.

Next Step
- Ask for the exact missing input, or state why no further change is justified.
```

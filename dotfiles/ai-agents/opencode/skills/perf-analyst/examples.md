# Examples

## 1. Primary Scenario

**Request**
Diagnose why this endpoint is slow under load.

**Good Response Shape**

```markdown
Task
- Restate the requested outcome.

Observed
- Cite the inputs or constraints that are actually available.

Deliverable
- Produce the requested performance diagnosis and optimization plan.

Validation
- List the smallest set of checks needed to confirm the result.

Risks
- Note the main failure mode or scope caveat.
```

---

## 2. Review or Triage Scenario

**Request**
Review this optimization plan for missing measurement steps.

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
Speed it up, but there are no traces, metrics, or code paths.

**Good Response Shape**

```markdown
Decision
- BLOCKER or NO CHANGE

Reason
- Explain whether the issue is missing input or unnecessary churn.

Next Step
- Ask for the exact missing input, or state why no further change is justified.
```

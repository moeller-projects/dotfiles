# Examples

## 1. Primary Scenario

**Request**
Split a limited budget across discovery, implementation, and validation.

**Good Response Shape**

```markdown
Task
- Restate the requested outcome.

Observed
- Cite the inputs or constraints that are actually available.

Deliverable
- Produce the requested session-wide budget policy.

Validation
- List the smallest set of checks needed to confirm the result.

Risks
- Note the main failure mode or scope caveat.
```

---

## 2. Review or Triage Scenario

**Request**
Review a plan that risks spending all budget in discovery.

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
The remaining budget cannot cover the requested final deliverable and validation.

**Good Response Shape**

```markdown
Decision
- BLOCKER or NO CHANGE

Reason
- Explain whether the issue is missing input or unnecessary churn.

Next Step
- Ask for the exact missing input, or state why no further change is justified.
```

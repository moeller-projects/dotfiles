# Evaluation Prompts

Use these prompts to detect drift in Budget Enforcement Supervisor (BES) v2 behavior.

## 1. Primary Task Handling

**Input**
Split a limited budget across discovery, implementation, and validation.

**Pass Criteria**
- stays within the skill's intended scope
- produces a concrete session-wide budget policy
- includes context-specific validation guidance

**Fail Criteria**
- returns only generic best practices
- drifts into unrelated implementation work

---

## 2. Review Scenario

**Input**
Review a plan that risks spending all budget in discovery.

**Pass Criteria**
- distinguishes observed facts from inferred concerns
- prioritizes the most important issue first
- recommends a concrete next step

**Fail Criteria**
- mixes evidence and speculation
- lists many low-value issues without prioritization

---

## 3. Blocker Scenario

**Input**
The remaining budget cannot cover the requested final deliverable and validation.

**Pass Criteria**
- states that a blocker exists when required input is missing
- names the missing input precisely
- explains why the missing input matters

**Fail Criteria**
- invents missing context
- proceeds as if the blocker does not exist

---

## 4. No-Change Scenario

**Input**
The current allocation already preserves validation and completion budget.

**Pass Criteria**
- allows a no-change conclusion when appropriate
- gives a concise evidence-based reason
- avoids churn for its own sake

**Fail Criteria**
- forces unnecessary changes
- rewrites or expands scope without evidence

---

## 5. Regression Checklist

A strong response should consistently:
- stay within the skill's domain boundaries
- produce a reusable artifact instead of vague advice
- surface assumptions honestly
- include validation or follow-up checks

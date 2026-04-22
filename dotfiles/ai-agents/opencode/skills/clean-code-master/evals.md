# Evaluation Prompts

## 1. No-Change Detection

Input:
A small, cohesive class with:
- low branching
- clear naming
- no duplication
- no boundary mixing

Expected:
- returns `NO CHANGE`
- does not invent refactors
- cites observed reasons

Pass criteria:
- no aesthetic churn
- no speculative issues
- explicit justification

---

## 2. Local Complexity Audit

Input:
One method with:
- 4 nested conditionals
- repeated validation
- direct use of current time

Expected:
- identifies structural + testability debt
- proposes low-risk steps
- includes verification guidance
- uses observed/inferred tags

Pass criteria:
- measurable improvement proposed
- no whole-file rewrite
- risk included

---

## 3. God Class Refactor Plan

Input:
A class with:
- many dependencies
- many public methods
- mixed responsibilities

Expected:
- classifies as structural debt
- produces incremental plan
- orders steps by safety
- requires characterization tests first

Pass criteria:
- no immediate rewrite
- no invented architecture
- medium/high-risk steps clearly marked

---

## 4. Boundary Mixing

Input:
A method that:
- validates domain rules
- writes to DB
- calls HTTP API
- updates cache

Expected:
- flags architectural debt
- identifies multi-boundary method
- recommends decomposition with risk
- mentions blast radius

Pass criteria:
- evidence grounded in code
- risk classification present
- verification included

---

## 5. CI Enforcement

Input:
A module with:
- score below 70
- one critical hotspot
- one budget violation

Expected:
- decision = Fail
- machine-readable JSON included
- budget violation called out explicitly

Pass criteria:
- correct fail reason
- JSON shape present
- final footer present

---

## 6. Missing Context But Safe Partial Analysis

Input:
A partial file with visible complexity issues, but no repo-wide architecture context

Expected:
- bounded analysis
- explicit assumptions
- no blocker unless architecture judgment is required

Pass criteria:
- avoids architecture fabrication
- still produces useful output

---

## 7. True Blocker

Input:
User requests repo-wide architectural refactor from a tiny diff with no surrounding files

Expected:
- returns `BLOCKER`
- states exact missing input
- asks one narrow question

Pass criteria:
- blocker is justified
- question is singular and specific

---

## 8. Patch Mode Discipline

Input:
User asks for “smallest worthwhile patch”

Expected:
- patch stays local
- no redesign plan
- no abstraction sprawl
- verification included

Pass criteria:
- minimal mutation
- measurable local improvement
- low or medium risk only unless explicitly required

---

## 9. Metric Honesty

Input:
Code where exact metrics cannot be computed reliably from snippet alone

Expected:
- uses approximate values with `~`
- marks inferred or assumed
- does not fabricate exact counts

Pass criteria:
- uncertainty handled explicitly
- no false precision

---

## 10. Severity Discipline

Input:
Several mixed findings:
- one naming issue
- one god class
- one multi-boundary hotspot

Expected:
- naming issue not over-ranked
- god class / multi-boundary issue prioritized
- severity tracks actual blast radius

Pass criteria:
- no severity inflation
- prioritization is rational

---

## Global Pass Criteria

A response passes when it:
- is deterministic
- is evidence-tagged
- avoids speculative rewrites
- prefers minimal worthwhile change
- includes verification for meaningful refactors
- returns `NO CHANGE` when appropriate
- uses `BLOCKER` only when truly necessary
````
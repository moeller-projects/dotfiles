# Skill Anti-Patterns

These are failures in how OpenSpec Expert v2.1 behaves.

They are not target-system bugs.
They are execution failures for the skill itself.

## 1. Scope Drift

Bad:
- using the skill for work outside OpenSpec document or review
- expanding into adjacent work without evidence or user need

Good:
- stay focused on the requested OpenSpec document or review
- defer unrelated work explicitly

---

## 2. Invented Context

Bad:
- assuming missing repository, environment, policy, or runtime details
- presenting guesses as facts

Good:
- label assumptions clearly
- return a blocker when the missing context changes the result materially

---

## 3. Generic Advice Instead of a Deliverable

Bad:
- returning broad commentary with no usable OpenSpec document or review
- describing best practices without connecting them to the request

Good:
- produce a concrete, reusable deliverable
- keep recommendations tied to the supplied context

---

## 4. Validation-Free Output

Bad:
- omitting checks, follow-up verification, or review criteria

Good:
- include the smallest useful validation plan
- state what evidence would confirm success

---

## 5. Unbounded Complexity

Bad:
- over-engineering the response beyond the requested scope
- adding process that does not improve reliability

Good:
- prefer the minimal structure that makes the output dependable
- keep the response proportional to the request

---

## 6. Missing Blocker or No-Change Decision

Bad:
- forcing a solution when key inputs are absent
- changing or expanding work without evidence that change is needed

Good:
- return a clear blocker when essential inputs are missing
- return no-change guidance when the current state already fits the goal

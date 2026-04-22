# Skill Anti-Patterns

These are failures in how Prompt Engineer behaves.

They are not target-system bugs.
They are execution failures for the skill itself.

## 1. Pattern Inflation

Bad:
- defaulting to chain-of-thought or multi-agent prompting for simple extraction
- adding examples and tools before proving they are needed

Good:
- start with the smallest prompt pattern that can satisfy the task
- escalate only when failure evidence justifies it

---

## 2. Baseline-Free Rewrites

Bad:
- replacing the whole prompt because outputs feel weak
- changing task wording, examples, schema, and temperature advice all at once

Good:
- identify the current failure mode first
- change one major variable at a time when diagnosing prompt problems

---

## 3. Provider Guessing

Bad:
- assuming JSON mode, tool calling, or context window behavior without provider context
- using vendor-specific syntax in a supposedly portable prompt

Good:
- stay provider-neutral by default
- use provider-specific features only when the user names the target environment

---

## 4. Hidden Assumptions

Bad:
- silently assuming audience, output format, safety rules, or token budget

Good:
- surface missing details in `Assumptions`
- block when those details materially change the deliverable

---

## 5. Example Overfitting

Bad:
- writing few-shot examples that memorize one edge case or contradict the task
- choosing examples that are cleaner than real production inputs

Good:
- choose examples that match the real input distribution
- include edge cases only when they teach a distinct behavior

---

## 6. Evaluation Theater

Bad:
- claiming a prompt is ready because it "looks better"
- listing vague checks like "test thoroughly"

Good:
- define concrete test cases, metrics, and pass criteria
- state when evaluation still needs user data or production monitoring

---

## 7. Prompt Bloat

Bad:
- repeating the same instruction in multiple sections
- stacking persona, policy, style, and formatting rules until they conflict

Good:
- remove redundant instructions
- keep only the constraints that change behavior materially

---

## 8. Runtime and Reference Mixing

Bad:
- embedding large tutorial content into the runtime response
- turning a simple deliverable into a lecture on prompt engineering

Good:
- keep runtime output operational
- point to reference material only when it changes the decision or user needs it

---

## 9. Unsupported Certainty

Bad:
- promising improved accuracy, latency, or cost without evidence
- claiming migration parity across models without testing

Good:
- qualify expected gains as hypotheses until validated
- highlight migration risk when provider behavior may differ

---

## 10. Missing `NO CHANGE`

Bad:
- rewriting a prompt that already meets the stated criteria

Good:
- use `NO CHANGE` when there is no evidence-backed reason to modify the current prompt

# Evaluation Prompts

Use these prompts to detect drift in runtime behavior.

## 1. Design a New Prompt

**Input**
Design a prompt that extracts shipping addresses into JSON.

**Pass Criteria**
- chooses `Design` mode
- returns `Decision: DELIVER`
- recommends a structured-output pattern
- includes explicit null or missing-field handling
- includes at least two concrete validation checks

**Fail Criteria**
- no output structure
- no validation section
- provider-specific syntax without provider context

---

## 2. Optimize an Existing Prompt

**Input**
Here is our current prompt and three failing outputs. Improve it without changing the task.

**Pass Criteria**
- chooses `Optimize` mode
- identifies observed failure type before rewriting
- preserves task scope
- avoids changing multiple unrelated variables without justification

**Fail Criteria**
- full rewrite with no diagnosis
- no distinction between observed and inferred issues

---

## 3. Evaluate Without Rewriting

**Input**
Create a regression plan for this support prompt. Do not rewrite the prompt yet.

**Pass Criteria**
- chooses `Evaluate` mode
- returns an evaluation plan instead of a replacement prompt
- defines metrics or pass criteria
- includes edge-case coverage

**Fail Criteria**
- rewrites the prompt anyway
- says only "test thoroughly"

---

## 4. Migrate Across Providers

**Input**
Adapt this OpenAI-specific prompt so it can run on multiple providers.

**Pass Criteria**
- chooses `Migrate` mode
- identifies provider-specific dependency in the existing prompt
- proposes a provider-neutral alternative
- warns about any portability trade-off

**Fail Criteria**
- assumes equivalent JSON mode support everywhere
- omits migration risks

---

## 5. Block on Missing Policy

**Input**
Rewrite this prompt so it complies with our internal policy, but I can't share the policy.

**Pass Criteria**
- returns `Decision: BLOCKER`
- names the missing input
- explains why the gap prevents a safe artifact

**Fail Criteria**
- invents policy rules
- claims compliance anyway

---

## 6. No-Change Decision

**Input**
Here is the current prompt, the test results all pass, and the user asks if it should be improved.

**Pass Criteria**
- returns `Decision: NO CHANGE`
- gives a concise evidence-based reason
- retains a validation recommendation

**Fail Criteria**
- rewrites the prompt without evidence

---

## Regression Checklist

A strong response should consistently:
- use one of the defined modes
- use `DELIVER`, `NO CHANGE`, or `BLOCKER`
- distinguish observed facts from assumptions when needed
- give concrete validation guidance
- avoid ornamental prompt-engineering lectures

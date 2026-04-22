# Examples

## 1. Design Mode -> Structured Extraction Prompt

**Request**
Design a prompt that extracts invoice data into JSON.

**Good Response Shape**

```markdown
Mode: Design
Decision: DELIVER

Task
- Extract invoice fields into valid JSON.

Observed
- Need machine-readable output.
- Missing values should not be fabricated.

Assumptions
- Provider is not specified.
- Downstream parser expects stable keys.

Recommendation
- Pattern: structured-output
- Why: parsing reliability matters more than free-form flexibility.

Deliverable
You are an invoice extraction assistant.

Extract the following fields from the input document:
- invoice_number: string | null
- invoice_date: string in YYYY-MM-DD format | null
- vendor_name: string | null
- total_amount: string | null

Rules:
- Return valid JSON only.
- Use null for fields not present.
- Do not infer missing values.

Input:
{invoice_text}

Output:
{
  "invoice_number": null,
  "invoice_date": null,
  "vendor_name": null,
  "total_amount": null
}

Validation
- Test with one complete invoice and one missing-field invoice.
- Verify invalid prose never appears outside JSON.

Risks
- Date normalization may vary across providers.
```

---

## 2. Optimize Mode -> Fix Inconsistent Classification

**Request**
This sentiment prompt keeps returning explanations even though I only want labels.

**Good Response Shape**

```markdown
Mode: Optimize
Decision: DELIVER

Observed
- Existing prompt allows free-form explanation.
- Failure symptom is output-format drift.

Inferred
- Missing hard output constraint is the main cause.

Recommendation
- Pattern: zero-shot
- Why: the task is simple; format control is the issue, not reasoning depth.

Deliverable
Classify the sentiment of the input text as POSITIVE, NEGATIVE, or NEUTRAL.
Return exactly one label from that set.
Do not include explanation or punctuation.

Input:
{text}

Validation
- Test one clearly positive, one clearly negative, and one ambiguous example.
- Fail if any output contains more than one token.
```

---

## 3. Evaluate Mode -> Prompt Test Plan

**Request**
Create evals for our support-answering system prompt.

**Good Response Shape**

```markdown
Mode: Evaluate
Decision: DELIVER

Task
- Define regression checks for the current support-answering prompt.

Observed
- Main risks are hallucination, tone drift, and missed escalation.

Recommendation
- Pattern: evaluation plan
- Why: the user asked for testable checks, not a prompt rewrite.

Deliverable
Test set:
- 6 typical support questions
- 2 ambiguous questions
- 2 escalation-required questions

Metrics:
- answer correctness
- escalation correctness
- tone compliance
- format compliance

Pass criteria:
- 100% escalation correctness
- >= 90% format compliance
- no fabricated policy statements

Validation
- Review failures by category before editing the prompt.
```

---

## 4. Migrate Mode -> Provider-Neutral Rewrite

**Request**
Move this OpenAI JSON-mode prompt to something portable.

**Good Response Shape**

```markdown
Mode: Migrate
Decision: DELIVER

Observed
- Current prompt depends on provider-enforced JSON mode.

Recommendation
- Pattern: provider-neutral structured-output
- Why: portability is the primary goal.

Deliverable
Rewrite the prompt to:
- describe the schema explicitly
- require valid JSON only
- define null and empty-array behavior
- avoid provider API syntax in the prompt body

Validation
- test on the target provider with malformed and empty inputs
- verify parser behavior on missing fields

Risks
- portable prompting may still be less strict than native JSON mode
```

---

## 5. `NO CHANGE`

**Request**
Should we rewrite this prompt?

**Good Response Shape**

```markdown
Mode: Optimize
Decision: NO CHANGE

Observed
- Existing prompt already meets the requested schema and safety rules.
- No failure examples were provided.

Reason
- A rewrite would add churn without evidence of benefit.

Validation
- Keep the current regression set and watch for format drift.
```

---

## 6. `BLOCKER`

**Request**
Make this compliant with our internal safety rules.

**Good Response Shape**

```markdown
Mode: Design
Decision: BLOCKER

Missing
- internal safety policy text
- required refusal or escalation rules

Why blocked
- the prompt cannot be aligned to a policy that was not supplied.

Next input needed
- provide the policy or the exact mandatory constraints.
```

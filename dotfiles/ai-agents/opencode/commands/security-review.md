---
description: Enterprise security-focused review
agent: review
---

# ENTERPRISE SECURITY REVIEW

Mode: Deterministic  
Scope: Diff or specified module  
Mutation: Forbidden  

Security-only analysis. Ignore style and cosmetic concerns.

---

## STEP 1 — SCOPE NORMALIZATION

Normalize scope:

- diff:<hash>
- module:<path>
- file:<path>

If unclear → STOP.

---

## STEP 2 — CACHE

If structural security artifacts exist:

- namespace: security-review
- key includes:
  - diff hash or module hash
  - governance version
  - skill_version

Call `analysis-cache`.
Reuse or store structured artifact.

---

## STEP 3 — SECURITY ANALYSIS DIMENSIONS

Evaluate:

### Input Validation
- Unvalidated inputs
- Deserialization risks
- Model binding weaknesses

### Injection
- SQL injection
- Command injection
- Template injection
- Path traversal

### Authentication & Authorization
- Missing checks
- Privilege escalation risk
- Insecure defaults

### Data Exposure
- Sensitive logging
- Overexposed DTOs
- Debug artifacts

### Dependency Risk
- Known insecure patterns
- Unsafe external calls

### Attack Surface Expansion
- New endpoints
- Public surface increase
- Event consumer expansion

---

## OUTPUT FORMAT

### Summary
Concise security posture overview.

### Findings

- Severity: Critical | High | Medium | Low
- Category:
- File:
- Evidence:
- Exploit Scenario:
- Mitigation:

If no high/critical issues:
"No critical security risks detected."

### Security Risk Level
Low | Moderate | Elevated | High

---

No patch suggestions.
No formatting advice.
Security focus only.
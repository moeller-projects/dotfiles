---
name: threat-modeler
description: Enterprise-grade security posture engineering skill for agentic coding. Performs asset-centric threat modeling, quantitative risk scoring, trust-boundary mapping, lateral movement analysis, compliance mapping, and produces actionable mitigations with verification hooks. Deterministic, evidence-tagged, and scope-tiered.
---

# Threat Modeler v2

## Intent

Engineer a measurable and governable security posture.

This skill goes beyond basic STRIDE enumeration and enables:

- Asset-centric threat modeling
- Quantitative risk scoring
- Trust boundary mapping
- Attack surface inventory
- Multi-tenant isolation analysis
- Event-driven security modeling
- Lateral movement analysis
- Secrets & configuration review
- Detection & observability mapping
- Compliance alignment (optional)
- Security regression test hooks

Designed for:

- SaaS platforms
- Multi-tenant systems
- Microservices and distributed systems
- Event-driven architectures
- Enterprise-grade CI/CD pipelines

---

# 1. Hard Rules (Safety & Evidence)

- No exploit instructions or weaponization details.
- No speculative infrastructure claims.
- All claims must be tagged:
  - [OBSERVED]
  - [INFERRED]
  - [ASSUMPTION]
- Prefer minimal, high-impact mitigations.
- If high-risk flow lacks sufficient context → Blocker Format.
- Never invent authentication or encryption controls.

---

# 2. Required Inputs (Minimal)

At least one:

- Entrypoint(s): endpoint/handler/consumer
- Workflow description or spec ID
- Relevant code snippet or diff
- Authentication / authorization mechanism (if known)
- Data sensitivity classification (if known)

If missing → Blocker Format.

---

# 3. Scope Tiering

Default: Medium

Small:
- Single endpoint or handler
- ≤3 files
- ≤15 threats
- 1 diagram

Medium:
- Single service workflow
- ≤12 files
- ≤35 threats
- 2 diagrams

Large:
- Cross-module workflow
- ≤25 files
- ≤60 threats
- 3 diagrams

Enterprise:
- Multi-service / multi-tenant
- ≤50 files (approval required)
- ≤100 threats
- 5 diagrams
- Requires explicit boundary list

---

# 4. Asset-Centric Modeling (Mandatory)

Identify and classify assets:

| Asset | Confidentiality | Integrity | Availability | Criticality (1–5) | Evidence |
|--------|----------------|-----------|-------------|------------------|----------|

Confidentiality/Integrity/Availability scale:
- Low
- Medium
- High

Criticality must consider:
- regulatory impact
- business continuity
- tenant isolation risk

---

# 5. Attack Surface Inventory (Mandatory)

Enumerate exposed surfaces:

| Surface | Type | Auth Required | Public/Internal | Evidence |
|----------|------|---------------|----------------|----------|

Types:
- HTTP endpoint
- Admin endpoint
- Webhook
- Queue consumer
- Scheduled job
- File upload
- Background worker
- Internal service API

---

# 6. Trust Boundary Map (Required for Medium+)

Produce Mermaid diagram.

Example:

```mermaid
flowchart LR
  Client -->|HTTPS| API
  API --> DB[(Database)]
  API --> MQ[(Message Bus)]
  MQ --> Worker
  API --> ThirdParty
````

Each boundary must be labeled:

* External
* Internal service
* Persistence
* Messaging
* Third-party

Tag inferred boundaries accordingly.

---

# 7. STRIDE-Lite Enumeration (Per Boundary)

For each boundary, analyze:

* Spoofing
* Tampering
* Repudiation
* Information Disclosure
* Denial of Service
* Elevation of Privilege

Tag each finding with evidence classification.

---

# 8. Quantitative Risk Scoring (Mandatory)

For each threat:

Risk Score = Impact (1–5) × Likelihood (1–5)

Produce:

| Threat | Boundary | STRIDE | Impact | Likelihood | Score | Priority | Evidence |
| ------ | -------- | ------ | ------ | ---------- | ----- | -------- | -------- |

Priority:

* Critical (≥20)
* High (15–19)
* Medium (8–14)
* Low (<8)

---

# 9. Lateral Movement Analysis

Evaluate:

* If Service A compromised, what can it access?
* Service-to-service auth enforcement
* Shared secrets reuse
* Cross-service database access
* Network segmentation assumptions

Output:

| Entry Compromise | Reachable Assets | Risk | Evidence |

---

# 10. Multi-Tenant Isolation Audit (If Applicable)

Check:

* Tenant ID always enforced in queries
* No cross-tenant caching
* Admin endpoints segregated
* Background jobs tenant-scoped
* Event routing tenant-aware

Unknown checks must be [ASSUMPTION].

---

# 11. Secrets & Configuration Review

Evaluate:

* Secrets in environment variables
* Hardcoded credentials
* Logging of sensitive data
* Secret propagation across services
* Rotation strategy presence (if observable)

Output:

| Secret Surface | Storage Pattern | Risk | Evidence |

---

# 12. Event-Driven Security Modeling (If Applicable)

Check:

* Message authenticity
* Schema validation
* Idempotency keys
* Replay protection
* Poison message handling
* Retry amplification risk
* DLQ presence

---

# 13. Detection & Observability Posture

For high-priority threats, assess:

* Audit logs present?
* Structured logging?
* Security event metrics?
* Alerting signals?
* Correlation IDs across boundaries?

Flag detection blind spots.

---

# 14. Compliance Mapping (Optional)

If requested, map threats to:

* OWASP Top 10 categories
* GDPR data handling risks
* SOC2 principles
* PCI/HIPAA (if applicable)

Example:

| Threat | OWASP Category | Compliance Impact |

Do not invent regulatory scope.

---

# 15. Mitigation & Verification Plan

For top 10 threats:

Provide:

* Preventive control
* Detective control
* Corrective control
* Verification method (test/config/log check)

Verification examples:

* Authorization unit test
* Input validation schema
* Rate limiting test
* Audit log assertion

No exploit examples.

---

# 16. Security Regression Hooks

Suggest CI hooks:

* SAST stage
* Dependency scanning
* Secret scanning
* Authorization test suite
* Replay/idempotency tests
* Rate limit configuration validation

Keep non-exploitative.

---

# 17. Output Structure

1. Scope & Assumptions (≤6 bullets)
2. Asset Classification Table
3. Attack Surface Inventory
4. Trust Boundary Diagram
5. Threat & Risk Matrix (sorted by Score desc)
6. Lateral Movement Table
7. Detection & Observability Gaps
8. Top Mitigation Actions (≤5)
9. Verification Plan
10. One focused question (if required)

Prefer tables over prose.

---

# 18. Blocker Format

Return ONLY:

* BLOCKER:
* REQUIRED INPUT:
* NEXT QUESTION:

---

# 19. End Marker

Append final line:

--END-THREAT-MODELER--
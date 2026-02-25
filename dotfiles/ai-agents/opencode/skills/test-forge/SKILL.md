---
name: test-forge
description: Elite production-grade test generation and strategy skill for agentic coding. Produces deterministic unit/integration/contract/property-based tests, diff-driven updates, branch/path coverage modeling, mutation-sensitive assertions, failure injection, compatibility guards, and test architecture governance. CI-ready and scope-tiered.
---

# Test Forge v2

## Intent
Engineer durable, high-signal automated tests with minimal churn.

Supports:
- Unit, integration, contract tests
- Property-based tests (optional) for pure logic/invariants
- Diff-driven test updates (changed behavior only)
- Branch/path coverage modeling and mapping to tests
- Mutation-sensitive assertions (behavior-distinguishing)
- Failure injection and resilience testing
- Async, concurrency, and event-driven flows (idempotency/replay safety)
- Compatibility guards for APIs/events/messages
- Test architecture governance (fixtures/builders/naming/placement)
- Test smell detection and remediation

Designed for:
- Large repos/monorepos
- Microservices and event-driven systems
- Spec-driven development
- OpenCode CLI automation
- Cost-governed sessions (pairs with budget-guard/budget-supervisor)

---

# 1. Hard Rules (Quality & Determinism)
- No hallucinated APIs, types, frameworks, test runners, or commands.
- Prefer deterministic tests: no sleeps; no real time; no randomness unless seeded; no external network.
- No production code changes unless explicitly requested. If testability is blocked, propose minimal seam changes and ask.
- Minimize churn: do not reformat unrelated files; avoid rewriting existing suites unless broken.
- Tests must validate behavior, not implementation details.
- If unknown inputs are required, ask one focused question and stop.

---

# 2. Required Inputs (Minimal)
Before writing tests, obtain at least one:
- `git diff` of the change (preferred)
- file path + function/class name + 20–120 line snippet
- failing test output excerpt (≤200–400 lines) if debugging

Also confirm (or infer with evidence):
- language/runtime (.NET/Node/Python/etc.)
- test framework (xUnit/NUnit/MSTest/Jest/Vitest/Pytest/etc.)
- mocking library/pattern (Moq/NSubstitute/FakeItEasy/Jest mocks/etc.)
- repository test conventions (folder naming, fixtures) if they exist

If unknown: ask exactly one focused question.

---

# 3. Scope Tiering (Complexity Control)
Default tier: Medium

Small:
- single unit (function/class)
- ≤2 test files
- ≤8 tests
- trace depth ≤2 hops
- no integration environment

Medium:
- 1–2 modules
- ≤5 test files
- ≤18 tests
- trace depth ≤3 hops
- allows in-memory fakes if repo supports

Large:
- cross-module workflow
- ≤10 test files
- ≤35 tests
- trace depth ≤4 hops
- allows 1 integration suite only if explicitly approved

Enterprise:
- multi-service/distributed
- ≤20 test files
- ≤70 tests
- trace depth ≤5 hops
- contracts/compatibility emphasized; integration only with explicit approval

If scope exceeds tier → Blocker Format (Section 16).

---

# 4. Deterministic Analysis Algorithm (What to Test)
For the target code/diff:

1) Identify behaviors changed/added (from diff/snippet/spec)  
2) Build branch/path model:
   - guard clauses
   - conditionals
   - early returns
   - exception paths
   - loop boundaries
3) Identify boundaries (I/O, persistence, message bus, clock)
4) Choose test types per policy:
   - unit first
   - contract/compatibility for public boundaries
   - integration only if requested/approved
5) Produce coverage matrices (Sections 5 and 6)
6) Generate tests with mutation-sensitive assertions (Section 7)
7) Run test smell checks (Section 15) and fix issues before output

---

# 5. Branch & Path Coverage Modeling (Mandatory for Medium+)
Produce a concise table:

| Branch/Path | Trigger | Expected Result | Proposed Test | Evidence |
|------------|---------|----------------|---------------|----------|

Evidence tags:
- [OBSERVED] code/spec/logs support it
- [INFERRED] derived from structure
- [ASSUMPTION] unknown; requires confirmation

All non-trivial rows must have an evidence tag.

---

# 6. Edge Case & Negative Path Matrix (Mandatory for Medium+)
Produce a second concise table:

| Case | Input/Condition | Expected | Type | Evidence |
|------|------------------|----------|------|----------|

Types: unit / integration / contract / property / perf-guard

---

# 7. Mutation Sensitivity Policy (Elite Assertions)
Every test must include assertions that would fail if logic is subtly wrong.

Rules:
- Avoid “not null only” assertions for business logic.
- Prefer asserting:
  - computed values
  - emitted events/messages
  - state transitions
  - persisted changes (via fake/in-memory boundary)
  - returned error types/codes

Mutation checklist:
- If operator flips (>, >=, ==) would test still pass? If yes → strengthen assertion.
- If constant changes (fee=5→6) would test still pass? If yes → add explicit value assertion.
- If branch removed would test still pass? If yes → add case targeting that branch.

---

# 8. Mock Discipline Rules (Anti-Brittle)
- Mock boundaries only (I/O, network, persistence, message bus, clock).
- Do not mock domain entities/value objects; build real instances via builders.
- Prefer state/result assertions over call-count assertions.
- If verifying calls, verify:
  - boundary interaction contract (e.g., publish called with expected payload)
  - not internal sequencing
- Avoid deep mock chains; introduce seam or fake instead if required.

---

# 9. Test Architecture Governance (Placement, Naming, Reuse)
Enforce consistent test architecture:

- Placement:
  - mirror production folder structure where applicable
  - keep unit vs integration separate directories if repo does

- Naming:
  - `Method_WhenCondition_ShouldOutcome` (or repo convention)
  - one behavior per test

- Reuse patterns:
  - Test data builders for complex domain objects
  - Shared fixtures only for expensive setup
  - Avoid hidden logic in setup; keep builders explicit

If repo has existing patterns, follow them.

---

# 10. Diff-Driven Mode (Delta Tests)
When `git diff` is provided:

1) Identify changed behavior(s)
2) Map to impacted tests
3) Update only those tests or add new minimal tests
4) Do not regenerate entire test suites

Output includes:
- impacted test areas list (paths)
- minimal patch

---

# 11. Compatibility & Contract Guards (Public Boundaries)
If change impacts:
- public API response/request shape
- event/message schema
- integration contracts

Add contract/compatibility tests:

- API:
  - required fields preserved
  - default values stable
  - versioned routes respected (if present)

- Events:
  - schema compatibility (required fields)
  - backward-compatible changes (additive fields ok; breaking changes flagged)

If schema/versioning is unknown:
- label [ASSUMPTION]
- ask a focused question.

---

# 12. Async, Concurrency, Idempotency, Replay Safety
If async/event-driven handlers exist, include (as applicable):

- Duplicate message replay test (idempotency)
- Out-of-order event test (if ordering relevant)
- Partial failure recovery test (failure injection)
- At-least-once delivery assumptions explicitly tagged

Avoid:
- `Thread.Sleep`
- flaky polling
Prefer:
- controlled schedulers/virtual time if available
- deterministic signaling (channels, latches) if repo supports

---

# 13. Failure Injection Mode (Resilience)
When boundaries exist (repo/client/bus), add deterministic failure tests:

- dependency throws exception
- timeout/cancellation (if supported deterministically)
- transient failure then success (if retry policy observable/configurable)

Rules:
- Only test retry behavior if deterministic and configurable.
- If retry policy unknown, mark [ASSUMPTION] and ask.

---

# 14. Performance Guard Mode (Lightweight)
Not benchmarking. Add regression guards only when critical path is touched.

Heuristics:
- loops with boundary calls
- repeated expensive operations
- large payload transformations

Possible tests:
- ensure method does not call boundary more than N times for N inputs (where observable)
- ensure linear scaling for small synthetic inputs (strictly deterministic)

If not feasible deterministically, note risk instead of writing flaky perf tests.

---

# 15. Test Smell Detection (Must Run Before Output)
Before finalizing, ensure tests are free of:

- assertionless tests
- multiple behaviors in one test
- excessive mocking
- brittle string matching (unless contract)
- hidden branching in setup
- reliance on order or shared global state

If a smell is detected, revise tests accordingly.

---

# 16. Blocker Format (Scope or Missing Inputs)
Return ONLY:
- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

Use when:
- unknown framework/test runner prevents correct test code
- scope exceeds selected tier
- entrypoint/behavior unclear and cannot be inferred safely

---

# 17. Output Discipline (CI-Friendly)
Default output:
1) Patch (tests only)
2) 3–8 bullets:
   - Coverage summary (branches/paths covered)
   - Compatibility/contract coverage (if any)
   - Flakiness protections used
   - How to run tests (command if observed; else ask)
   - Remaining risks/assumptions
3) One focused question if needed

Avoid long explanations unless requested.

---

# 18. End Marker
Append final line:

--END-TEST-FORGE--
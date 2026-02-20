---
name: perf-analyst
description: Enterprise-grade performance engineering skill for agentic coding. Performs deterministic hotspot analysis, workload modeling, capacity estimation, tail-latency analysis, backpressure evaluation, scaling risk detection, and produces minimal safe optimization patches with measurement and rollout plans.
---

# Perf Analyst v2

## Intent

Engineer predictable, scalable, and measurable performance improvements.

This skill moves beyond “code optimization” and focuses on:

- Workload-aware performance engineering
- Capacity estimation
- Tail latency reduction
- Backpressure & resilience analysis
- Horizontal scalability validation
- Observability integration
- Safe rollout strategy
- Deterministic regression guards

Designed for:
- SaaS systems
- Microservices
- Distributed/event-driven architectures
- High-concurrency APIs
- CI/CD performance governance

---

# 1. Hard Rules (Safety & Determinism)

- Never invent performance numbers.
- Never claim improvement without a measurement plan.
- Do not broaden scope beyond the defined hot path.
- Prioritize algorithmic and I/O improvements over micro-optimizations.
- All recommendations must include risk classification.
- No flaky timing-based CI assertions.
- No speculative infrastructure assumptions.

---

# 2. Required Inputs (Minimal)

Before performing analysis, require at least one:

- Target scenario (endpoint/job/handler)
- Load expectations (QPS, concurrency, SLA)
- Profiling output (trace, flamegraph, counters)
- Relevant code snippet (40–150 lines)
- `git diff` for regression analysis

If missing:

Return only:
- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 3. Scope Tiering

Default: Medium

Small:
- Single function/class
- ≤3 files
- ≤6 findings
- No distributed modeling

Medium:
- Single module/service
- ≤12 files
- ≤12 findings
- Includes workload model

Large:
- Cross-module workflow
- ≤25 files
- ≤20 findings
- Includes tail-latency modeling

Enterprise:
- Multi-service/distributed
- ≤50 files
- ≤30 findings
- Includes capacity estimation + scaling analysis

If scope exceeds tier → Blocker Format.

---

# 4. Workload Modeling (Mandatory for Medium+)

Before optimization, define:

- Expected QPS / RPS
- Concurrency level
- Request/response size
- Burst vs steady load
- SLA (p50/p95/p99 target)

If not provided:
- Request minimal workload description.

Performance is evaluated relative to workload.

---

# 5. Deterministic Analysis Algorithm

1. Identify entrypoint.
2. Build Hot Path Map:
   - CPU-bound segments
   - I/O boundaries
   - Async boundaries
   - Locking/contention zones
   - Serialization boundaries
3. Classify cost drivers:
   - Latency
   - Throughput
   - Allocation/GC
   - Contention
   - External dependency latency
4. Rank by expected ROI.
5. Propose minimal safe patch.
6. Define measurement plan.
7. Define regression guard.
8. Define rollout strategy.

---

# 6. Hot Path Map (Required)

| Step | Component | Boundary | Cost Type | Evidence |
|------|-----------|----------|----------|----------|

Boundary: CPU / DB / HTTP / Cache / FS / Queue / Lock  
Cost Type: latency / throughput / allocation / contention  

Evidence tags:
- [OBSERVED]
- [INFERRED]
- [ASSUMPTION]

---

# 7. Capacity Estimation (Enterprise)

Provide coarse estimation:

- Requests/sec per instance (qualitative)
- CPU saturation risk
- Memory headroom
- Thread pool exhaustion risk
- DB connection pool risk
- Queue backlog growth risk

No invented numbers — describe saturation risks logically.

---

# 8. Tail Latency Analysis (Mandatory for Large+)

Identify p99 amplification causes:

- Sequential I/O chains
- Fan-out/fan-in aggregation
- Retry amplification
- High-variance downstream dependency
- Lock convoying
- GC pause spikes

Recommend variance reduction strategies.

---

# 9. Backpressure & Load Shedding Analysis

Check for:

- Bounded queues
- Semaphore limits
- Rate limiting
- Circuit breakers
- Retry policies
- Bulkhead isolation

If absent, recommend patterns.

---

# 10. Scaling Readiness Check

Detect blockers:

- Shared mutable static state
- Sticky session dependency
- In-memory caches without distribution
- Thread affinity logic
- Global locks
- Large critical sections

Document scaling constraints.

---

# 11. Database Analysis Heuristics

If persistence involved:

Flag:

- N+1 query patterns
- Missing pagination
- SELECT *
- Missing projection narrowing
- Large transaction scopes
- Missing batching
- Excessive round trips

Do not invent schema — mark as [ASSUMPTION] if unclear.

---

# 12. Allocation & GC Modeling

Classify:

- Short-lived allocations
- Long-lived allocations
- Large Object Heap risks
- Object pooling candidates
- Repeated string concatenation
- LINQ in hot loops
- Boxing in loops

Flag only when in hot path.

---

# 13. Observability Recommendations

Recommend:

- Histogram metrics (p50/p95/p99)
- Request duration metrics
- Queue length metrics
- Cache hit ratio
- DB query count per request
- Distributed tracing spans
- Correlation IDs across services

No code generation unless requested.

---

# 14. Patch Policy

Optimization patches must:

- Be minimal and reversible
- Preserve semantics
- Include risk classification:

| Optimization | Risk Type |
|--------------|-----------|
| caching | staleness |
| batching | ordering |
| parallelization | race conditions |
| async rewrite | deadlock risk |
| lock removal | data corruption |
| query change | functional correctness |

---

# 15. Perf Regression Guards (Non-Flaky)

Allowed:

- Query count guard (if observable)
- Boundary call count guard
- Complexity invariant checks
- Allocation ceiling only if stable
- Microbenchmarks only if repo supports harness

Not allowed:

- Wall-clock assertions in CI

---

# 16. Rollout & Risk Mitigation Plan

For significant changes:

Recommend:

- Feature flag
- Canary deployment
- Gradual rollout
- Metric gating
- Rollback condition

Keep concise.

---

# 17. Output Structure

1. Executive Summary (≤6 bullets)
2. Workload Model
3. Hot Path Map
4. Ranked Findings
5. Proposed Patch(es)
6. Capacity & Tail Analysis
7. Measurement Plan
8. Regression Guards
9. Rollout Plan
10. Risk Table

Keep output structured and concise.

---

# 18. Blocker Format

Return ONLY:

- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 19. End Marker

Append final line:

--END-PERF-ANALYST--
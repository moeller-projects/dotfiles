---
name: monorepo-navigator
description: Enterprise-grade architectural intelligence and monorepo analysis skill. Builds deterministic module graphs, computes structural metrics, detects architectural drift, bounded contexts, cycles, ownership boundaries, blast radius, and produces CI-ready reports and diagrams with strict scope control.
---

# Monorepo Navigator v2

## Intent

Provide architectural intelligence for large repositories.

This skill goes beyond simple dependency mapping and enables:

- Deterministic module inventory
- Dependency graph extraction
- Graph metrics computation
- Bounded context inference
- Architectural violation detection
- Drift detection over time
- Ownership & cross-team dependency mapping
- Temporal coupling analysis
- Blast radius estimation
- Architectural health scoring
- CI-friendly structural reporting

Designed for:

- Large monorepos
- Modular SaaS platforms
- Microservice codebases
- Polyglot repositories
- Spec-driven and agentic workflows

---

# 1. Hard Rules (Determinism & Evidence)

- No hallucinated modules or dependencies.
- Prefer manifest/build-system truth over import scanning.
- Separate findings into:
  - [OBSERVED]
  - [INFERRED]
  - [ASSUMPTION]
- Respect scope tier limits strictly.
- Never recursively scan entire repo unless tier allows.
- Produce CI-friendly deterministic output.

---

# 2. Required Inputs (Minimal)

At least one:

- Repository root (sandbox access)
- Top-level directory listing
- Build manifests (.sln, csproj, package.json, pnpm/yarn workspace, pyproject.toml, Bazel, etc.)
- Optional: git availability

If insufficient context:

Return only:

- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 3. Scope Tiering

Default: Medium

Small:
- ≤3 top-level directories
- ≤40 files inspected (manifests preferred)
- 1 diagram
- No drift or temporal analysis

Medium:
- Full module inventory via manifests
- ≤150 files inspected
- ≤2 diagrams
- Basic graph metrics
- Optional churn summary (top 10)

Large:
- Scoped deep graph + selective import analysis
- ≤400 files inspected
- ≤4 diagrams
- Drift detection enabled
- Temporal coupling enabled

Enterprise:
- Architectural audit mode
- ≤800 files inspected (requires approval)
- ≤6 diagrams
- Full health scoring
- Ownership + blast radius + context clustering

If limits exceeded → Blocker Format.

---

# 4. Deterministic Discovery Algorithm

## Phase A — Build System Detection

Identify:

- .NET: .sln, *.csproj, Directory.Build.*
- Node: package.json workspaces, pnpm/yarn config
- Python: pyproject.toml, requirements
- Other: Bazel/Gradle/Maven/etc.

Mark runtime per module as [OBSERVED].

---

## Phase B — Module Inventory

For each module:

| Module | Type | Path | Manifest | Runtime | Evidence |

Type classification (if inferable):

- service
- library
- application
- shared
- tooling
- infrastructure

Type inference must be tagged [INFERRED].

---

## Phase C — Dependency Graph Extraction

Primary sources:

- project references (csproj)
- workspace deps
- declared dependencies

Import scanning only if tier ≥ Large and scoped.

Produce edge list:

A → B (manifest/import)

---

# 5. Graph Metrics (Architectural Intelligence)

Compute per module:

| Module | In-Degree | Out-Degree | SCC Size | Depth | Centrality (approx) | Risk |

Definitions:

- In-Degree: number of incoming edges
- Out-Degree: number of outgoing edges
- SCC Size: strongly connected component size
- Depth: distance from root modules
- Centrality: relative structural importance (approx via degree + position)

Risk heuristics:

- High In + High Out → God Module
- Large SCC → Cycle cluster
- Deep chains → Change fragility

---

# 6. Cycle Detection

Detect strongly connected components.

Report:

- cycle chains
- minimal edge cut suggestions [INFERRED]

Example:

ModuleA → ModuleB → ModuleC → ModuleA

---

# 7. Bounded Context Clustering (DDD-Aware)

Cluster modules based on:

- High internal edge density
- Low external dependencies
- Naming conventions

Produce:

| Context (Inferred) | Modules | Cross-Context Edges | Evidence |

All contexts must be tagged [INFERRED].

---

# 8. Architectural Violation Detection

If ruleset exists (depcruise/nx/custom docs):

- enforce layer rules
- detect inversion
- detect forbidden edges

If no ruleset:

- infer likely layers (UI/App/Domain/Infra/Shared)
- flag potential violations as [INFERRED]

---

# 9. Drift Detection (If Git Available)

Compare current structural signals against previous state:

- New cycles
- Increased fan-out
- Increased SCC size
- Increased cross-context edges

Report:

| Drift Signal | Direction | Severity |

If no baseline exists, mark as [ASSUMPTION].

---

# 10. Temporal Coupling Analysis (If Git Available)

Detect:

- Files/modules frequently changed together
- Cross-context co-change patterns
- High churn + high coupling

Output:

| Module | Churn Rank | Coupling Rank | Risk |

Limit to top 10 results.

---

# 11. Ownership Mapping (If CODEOWNERS Exists)

Parse ownership file if available.

Produce:

| Module | Owner | Cross-Team Dependencies | Risk |

If not available, mark [ASSUMPTION].

---

# 12. Blast Radius Estimation

Given module X:

Compute transitive downstream impact.

Output:

| Module | Distance | Impact Level |

Impact heuristic:

- Distance 1 → Direct
- Distance 2 → Moderate
- Distance ≥3 → Wide

Use this for safe refactoring planning.

---

# 13. Scaling & Extraction Signals

Identify modules suitable for:

- microservice extraction
- shared kernel isolation
- dependency inversion
- splitting god modules

All recommendations must be [INFERRED].

---

# 14. Architectural Health Score

Compute qualitative health:

Metrics considered:

- Cycle count
- Largest SCC size
- Average fan-out
- High centrality modules
- Cross-context leakage
- Temporal coupling concentration

Output:

Architecture Health: Good / Warning / Critical

Provide short justification.

---

# 15. Diagram Generation (Mermaid Default)

## Dependency Graph (Top 20 by Degree)

```mermaid
graph TD
  A[ModuleA] --> B[ModuleB]
  B --> C[ModuleC]
````

## Context Cluster View

```mermaid
graph LR
  subgraph ContextA
    A1 --> A2
  end
  subgraph ContextB
    B1 --> B2
  end
  A2 --> B1
```

Rules:

* No invented nodes
* Consistent naming
* Avoid over-dense graphs (respect tier)

---

# 16. Navigation Plan (Agentic-Friendly)

Provide:

* Entry modules for feature work
* Minimal file set to inspect first
* Key configuration files
* Boundary hotspots
* Safe change radius

Keep concise and actionable.

---

# 17. Output Discipline

Always include:

1. Module Map
2. Dependency Edge List
3. Graph Metrics Table
4. Cycle Report (if any)
5. Context Clusters (if applicable)
6. Architectural Health Summary
7. Navigation Plan

Use tables and diagrams over prose.

---

# 18. Blocker Format

Return ONLY:

* BLOCKER:
* REQUIRED INPUT:
* NEXT QUESTION:

---

# 19. End Marker

Append final line:

--END-MONOREPO-NAVIGATOR--
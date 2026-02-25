---
name: doc-forge
description: Enterprise-grade documentation and workflow analysis skill for complex codebases. Generates inline docs, structured documents, ADRs, traceability matrices, delta updates, and deterministic diagrams with evidence tagging.
---

# Doc Forge v2

## Intent

Deterministic, production-grade documentation for:

- Inline documentation (XML docs / JSDoc / docstrings)
- Standalone docs (Architecture, Module, API, Workflow)
- ADRs
- Diagrams (Mermaid default, PlantUML/C4 optional)
- Delta documentation updates from diffs
- Traceability matrices
- Glossary extraction
- Security and performance documentation

Designed for:
- Large repositories
- Monorepos
- Microservices
- Event-driven systems
- CI documentation pipelines

---

# 1. Core Guardrails (Hard Rules)

- No hallucinated architecture.
- Never assume frameworks, runtimes, or boundaries without evidence.
- Always distinguish:
  - [OBSERVED]
  - [INFERRED]
  - [ASSUMPTION]
- Prefer tables and diagrams over prose.
- Keep outputs deterministic and CI-safe.

---

# 2. Evidence Tagging (Mandatory)

Use these markers:

- [OBSERVED] directly supported by source code, config, or logs
- [INFERRED] logically derived from structure
- [ASSUMPTION] unknown, requires confirmation

Never present inferred behavior as observed fact.

---

# 3. Complexity Tiering

Default tier: Medium

Tier definitions:

Small:
- Single file/class
- ≤3 files
- ≤1 diagram
- Trace depth ≤2 hops

Medium:
- Single module
- ≤10 files
- ≤2 diagrams
- Trace depth ≤3 hops

Large:
- Cross-module workflow
- ≤25 files
- ≤3 diagrams
- Trace depth ≤4 hops

Enterprise:
- Multi-service / distributed
- ≤50 files
- ≤5 diagrams
- Trace depth ≤5 hops

If scope exceeds tier:

Return only:
- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 4. Deterministic Workflow Extraction Algorithm

Given an entrypoint:

1. Identify entrypoint symbol.
2. Extract direct method calls (Hop 1).
3. Identify injected dependencies.
4. Trace dependency calls up to allowed depth.
5. Mark boundaries:
   - network
   - persistence
   - message bus
   - filesystem/cache
6. Stop when:
   - max depth reached
   - external boundary reached
   - recursion detected
7. Record:
   - sync/async
   - boundary type
   - side effects
   - evidence tags

Never recurse unbounded.

---

# 5. Modes

## Inline Mode

Add structured inline documentation.

Document:
- intent
- preconditions
- postconditions
- side effects
- exceptions
- async behavior
- transactions
- idempotency
- thread safety

Skip trivial getters/setters.

Output:
Patch only.

---

## Structural Document Mode

Create standalone Markdown documents.

Default structure:

1. System Overview
2. Module Responsibilities
3. Data Flow
4. Dependencies
5. Runtime Behavior
6. Failure Modes
7. Security Notes
8. Performance Notes
9. Extension Points

Include metadata block at top:

<!--
Generated-By: doc-forge v2
Analysis-Tier: <tier>
Analysis-Scope: <scope>
Source-Refs: <paths/symbols summary>
-->

---

## Workflow Mode

Output:

1. Workflow Summary
2. Step-by-step Flow (table)
3. Boundaries & Transitions
4. Failure Scenarios
5. Performance Considerations
6. Security Considerations
7. Diagram(s)

Each step must include:
- sync/async
- boundary type
- side effects
- evidence tag

---

## Diagram Mode

Supported:
- Mermaid (default)
- PlantUML
- C4-PlantUML
- Sequence
- Component
- State
- Event-flow
- Flowchart

Output diagram code only unless explanation requested.

---

## Delta Documentation Mode

Input:
- git diff or changed files

Output:
- impacted doc sections
- patch updating only those sections

Never regenerate entire document unnecessarily.

---

## Glossary Mode

Extract domain terms from:
- entities
- value objects
- enums
- events
- public API models

Output table:

| Term | Definition | Evidence |

Definitions must be [OBSERVED] or [INFERRED].

---

## Traceability Mode

Provide matrices such as:

HTTP/API Traceability:

| Endpoint | Handler | Service | Repo/DB | Events | Evidence |

Event Traceability:

| Event | Producer | Consumer | Side Effects | Evidence |

---

## Security Flow Mode

Document:
- authentication boundary
- authorization enforcement
- trust boundaries
- input validation
- sensitive data handling
- external attack surface

Unknowns must be [ASSUMPTION].

---

# 6. Diagram Auto-Selection

Unless specified:

- Sync request/response → Sequence diagram
- Event-driven → Event-flow + optional sequence
- Multi-module → Component diagram
- State transitions detected → State diagram
- Business process logic → Flowchart

Default fallback: Sequence diagram.

---

# 7. Diagram Consistency Rules

- Use consistent naming across diagrams.
- Do not mix abstraction levels.
- Do not invent components.
- Split diagrams if too dense.
- Stay within diagram limit per tier.

---

# 8. Cross-Document Linking

Use stable paths under docs/.

Link deterministically:

Architecture ↔ Workflows ↔ ADRs

No timestamps in anchors.

---

# 9. Performance Heuristics

Flag as Potential Bottleneck when [OBSERVED]:

- DB calls inside loops
- sequential awaits
- blocking in async context
- N+1 query pattern
- missing pagination limits

Mark uncertain cases as [INFERRED].

---

# 10. Async & Event Awareness

When detected, document:

- producer(s)
- consumer(s)
- delivery semantics (if observed)
- retry behavior (if observed)
- idempotency requirements

Unknown behavior must be [ASSUMPTION].

---

# 11. Spec Awareness

If specs exist:

- Prefer section IDs over copying entire specs.
- Treat spec excerpts as [OBSERVED].
- Use Delta mode when specs change.

---

# 12. Blocker Format

If scope too large or entrypoint missing:

Return only:

- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 13. Output Discipline

Inline mode → patch only  
Document mode → full document only  
Diagram mode → diagram code only  

Avoid conversational commentary.

---

# 14. End Marker

Append this as the final line:

--END-DOC-FORGE--

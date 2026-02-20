POLICY: analysis-cache
VERSION: v1
SCOPE: session-level + repo-level artifact caching for deterministic structural analyses
INTENT: reduce token/tool cost by reusing stable, evidence-based analysis artifacts across iterative Codex sessions

======================================================================
1) POSITIONING
======================================================================
analysis-cache is a POLICY LAYER (interceptor), not a task skill.

Execution order (recommended):
User Request
  -> budget-supervisor (governance)
  -> analysis-cache (cache decision + artifact reuse)
  -> skill execution (only if cache miss/invalid)
  -> analysis-cache (store artifacts)
  -> budget-supervisor (usage accounting)

analysis-cache MUST NOT:
- create patches
- modify repo content
- run builds/tests
- perform internet searches

analysis-cache MAY:
- read repo files needed for hashing/invalidation
- store/retrieve artifacts
- emit short cache decision logs (≤6 lines)

======================================================================
2) ARTIFACT MODEL
======================================================================
Cache artifacts, not raw LLM responses.

Artifact types (suggested):
- module_map
- dependency_graph
- scc_cycles_report
- graph_metrics
- bounded_context_clusters
- ownership_map
- temporal_coupling_summary
- blast_radius_map
- api_surface_map
- invariants_table
- attack_surface_inventory
- threat_risk_matrix
- mitigation_plan
- coverage_branch_map
- test_plan_delta
- workflow_trace_map
- diagram_mermaid

Each artifact MUST be stored as structured JSON/YAML + optional rendered Markdown/diagram.
Artifacts MUST include evidence pointers (file paths, symbol names) where applicable.

Artifact record schema (minimum):
- artifact_id (content-addressed)
- artifact_type
- skill_name
- skill_version
- repo_id
- scope_id
- inputs_fingerprint
- dependency_fingerprint
- invariants_fingerprint (optional)
- created_at (optional; not used for invalidation)
- payload (structured)
- render (optional)
- evidence (array of {path, symbols?, notes?})

======================================================================
3) CACHE KEYING (CONTENT-ADDRESSED)
======================================================================
Cache key MUST be computed from stable signals only.

Key components:
- skill_name
- skill_version
- repo_id
- scope_id (normalized)
- inputs_fingerprint (normalized, volatility-stripped)
- dependency_fingerprint (structural)
- policy_version

Key derivation:
cache_key = HASH(
  policy_version +
  skill_name + skill_version +
  repo_id +
  scope_id +
  inputs_fingerprint +
  dependency_fingerprint
)

Rules:
- Do NOT include timestamps, run IDs, build numbers, absolute dates.
- Do NOT include full prompt text unless in normalized condensed form.
- Normalize whitespace and ordering in lists.
- Use deterministic serialization (sorted keys).

======================================================================
4) SCOPE NORMALIZATION
======================================================================
analysis-cache MUST normalize scope to prevent cache fragmentation.

Scope identifiers:
- module:<path>
- project:<manifest path>
- workflow:<entrypoint symbol>
- surface:<api/controller/interface>
- diff:<git diff hash>
- repo:<root> (only for Enterprise tier and explicit)

Normalize:
- paths to repo-relative
- symbols to fully-qualified names (when possible)
- lists sorted and de-duplicated

======================================================================
5) FINGERPRINTS (HASH-BASED INVALIDATION)
======================================================================
Invalidation is hash-based, never time-based.

5.1) repo_id
Derive from one of:
- git remote URL + default branch (if available)
- hash of repo root path + top-level manifest set (fallback)

5.2) inputs_fingerprint
Normalized from:
- task category (e.g., “graph”, “surface”, “threat”, “tests”)
- scope_id
- user constraints flags (e.g., “no integration tests”, “mermaid only”)
- diff hash if in delta mode

5.3) dependency_fingerprint (structural)
Computed from relevant file hashes (see Section 6).

Optional:
- invariants_fingerprint for refactor semantics
- threat_boundary_fingerprint for security posture artifacts

======================================================================
6) DEPENDENCY FINGERPRINT SOURCES (BY ARTIFACT TYPE)
======================================================================
Use minimal file sets, manifest-first.

6.1) dependency_graph / module_map / graph_metrics / cycles / clusters
Hash inputs:
- .NET: *.sln, **/*.csproj, Directory.Build.props/targets, nuget.config
- Node: package.json (root + packages), pnpm-workspace.yaml, yarn.lock/pnpm-lock.yaml (optional), nx.json (if present)
- Python: pyproject.toml, requirements*.txt, poetry.lock (optional)
- Build rules: Bazel/Gradle/Maven manifests if present
- Repo structure: top-level dir list (optional)

6.2) api_surface_map
Hash inputs:
- files declaring public endpoints/contracts (e.g., Controllers, OpenAPI specs, public interfaces)
- routing configs (if present)
- shared DTO/event schema files

6.3) invariants_table
Hash inputs:
- specific file(s) containing the target behavior + direct dependencies involved in the behavior
- diff hash if in delta mode

6.4) threat_risk_matrix / attack_surface_inventory
Hash inputs:
- entrypoint files (controllers/handlers/consumers)
- auth configs (if present)
- routing/ingress configs (if present)
- message contracts (events/schemas)
- relevant infra-as-code snippets if in repo

6.5) coverage_branch_map / test_plan_delta
Hash inputs:
- diff hash
- tested unit/module files
- test project manifests

6.6) diagrams
Hash inputs:
- the underlying artifact they visualize (graph/workflow/threat map) not raw text.

======================================================================
7) CACHE POLICY MODES
======================================================================
Modes control strictness and behavior.

- OFF:
  no caching

- NORMAL (default):
  reuse on exact cache key match

- AGGRESSIVE:
  reuse when:
    - dependency_fingerprint matches
    - scope_id matches
    - skill_version matches
  even if minor input text differs (after normalization)

- STRICT-CI:
  reuse only;
  if miss would require recomputation beyond allowed tool budget, return blocker

Mode selection should be controlled by budget-supervisor/session config.

======================================================================
8) STALENESS & VALIDATION
======================================================================
On cache HIT:
- Validate artifact integrity:
  - required fields present
  - evidence paths still exist (best-effort)
- If validation fails -> treat as MISS and log cache_corrupt.

No time-based staleness expiration.
Optional size-based eviction only.

======================================================================
9) STORAGE FORMAT & LOCATION
======================================================================
Store artifacts in repo-local cache directory:

- .codex/cache/analysis-cache/

Layout:
- index.json (or sqlite) for lookup
- artifacts/<artifact_id>.json (structured payload)
- renders/<artifact_id>.md (optional)
- diagrams/<artifact_id>.mmd (optional)

Atomic writes:
- write temp then rename

Corruption handling:
- if index unreadable -> rebuild index from artifacts directory (best-effort)
- if artifact unreadable -> ignore artifact, log cache_corrupt

======================================================================
10) DECISION LOGGING (TOKEN-LIGHT)
======================================================================
analysis-cache emits at most 6 lines:

- CACHE: HIT/MISS/STALE/CORRUPT
- ARTIFACT: <type>
- SCOPE: <scope_id>
- KEY: <short hash prefix>
- ACTION: reused/recompute/store
- NOTE: <reason if miss>

No verbose explanations.

======================================================================
11) SECURITY & PRIVACY
======================================================================
- Cache must not store secrets.
- Redact:
  - tokens
  - credentials
  - connection strings
  - PII where possible
- If artifact contains sensitive material:
  - store only hashes + pointers
  - or store redacted payload with evidence pointers

Access control:
- artifacts are local to repo by default
- no cross-repo sharing unless explicitly configured

======================================================================
12) INTEGRATION CONTRACT (WITH SKILLS)
======================================================================
Skills that benefit must output structured artifacts.

Minimum contract:
- skill_name, skill_version
- scope_id
- dependency inputs list (paths)
- payload in structured format

analysis-cache should wrap these skills by default:
- monorepo-navigator
- refactor-engine (planning artifacts: invariants, surface, impact matrices)
- threat-modeler (asset/surface/threat matrices)
- doc-forge (workflow traces, diagrams, module maps)
- test-forge (coverage/branch maps, test plans)

Do NOT cache:
- runtime log analyses
- live profiling outputs
- web searches

======================================================================
13) INVALIDATION TRIGGERS (SUMMARY)
======================================================================
Recompute on:
- skill_version change
- policy_version change
- scope_id change
- dependency_fingerprint mismatch

Prefer chain invalidation:
- dependency_graph change invalidates blast_radius_map
- api_surface_map change invalidates threat_risk_matrix
- workflow trace change invalidates diagrams

======================================================================
14) OPERATIONAL CONTROLS
======================================================================
- Manual override flags:
  - FORCE_RESCAN (ignore cache once)
  - CLEAR_SCOPE_CACHE (scope-specific)
  - CLEAR_ALL_CACHE

- Budget interaction:
  - In STRICT-CI mode, if recompute would exceed remaining budget -> Blocker

Blocker format:
- BLOCKER: cache miss and recompute exceeds budget
- REQUIRED INPUT: enable override OR narrow scope
- NEXT QUESTION: proceed with override?

======================================================================
15) VERSIONING
======================================================================
- policy_version is part of cache key
- any structural schema change increments policy_version
- skills include skill_version; changing skill output schema must bump it

======================================================================
16) QUICK START (HOW TO USE)
======================================================================
Session config (conceptual):

analysis-cache:
  enabled: true
  mode: aggressive
  store_renders: true
  max_artifacts: 5000
  redact_secrets: true

CI config:

analysis-cache:
  enabled: true
  mode: strict-ci
  store_renders: false

User invocation examples (within a Codex session):
- "Enable analysis-cache in aggressive mode for this session."
- "Force rescan for monorepo-navigator graph only."
- "Clear scope cache for module:modules/orders."

======================================================================
END POLICY
======================================================================
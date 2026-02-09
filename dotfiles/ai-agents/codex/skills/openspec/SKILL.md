# Skill: openspec (Production, deterministic)

## Purpose
Create/update OpenSpec specifications using the OpenSpec CLI in a deterministic, CI-safe way.

## Mandatory behavior
- You MUST use the provided scripts under ./scripts.
- You MUST NOT hand-write full specs if openspec CLI + scripts can do it.
- You MUST validate using: scripts/validate_spec.sh
- You MUST apply policies (validate_spec.sh runs them).

## Allowed inputs
- Plain task text (feature/bug description)
- Azure DevOps work item id (preferred for team workflows)
- A prepared requirements JSON (from deep-research skill)

## Primary entrypoints
- scripts/spec_from_input.sh "<task text or path>"
- scripts/spec_from_ado.sh <workitem-id>

## Output contract
At the end, report:
- Spec name
- Paths touched (spec file)
- Validation status (pass/fail)
- If fail: exact failing step + log hint

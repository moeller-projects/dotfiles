# OpenSpec skill (prod)

## Requirements
- openspec CLI available in PATH
- bash
- jq
- curl
- git (optional but recommended)

## Azure DevOps env
export AZURE_DEVOPS_PAT="..."
export ADO_ORG="myorg"
export ADO_PROJECT="myproject"
# Optional (defaults to https://dev.azure.com)
export ADO_BASE_URL="https://dev.azure.com"

## Usage
# From ADO work item
.codex/skills/openspec/scripts/spec_from_ado.sh 12345

# From task text
.codex/skills/openspec/scripts/spec_from_input.sh "Add retry with exponential backoff for outbound HTTP calls"

# From requirements JSON produced by deep-research
.codex/skills/openspec/scripts/spec_from_input.sh .research/20260209-xxxx/requirements.json

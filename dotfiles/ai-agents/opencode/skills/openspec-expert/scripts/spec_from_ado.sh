#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"

"$DIR/ensure_env.sh"

id="${1:?work item id required}"
org="${ADO_ORG:?ADO_ORG missing}"
project="${ADO_PROJECT:?ADO_PROJECT missing}"
base="${ADO_BASE_URL:-https://dev.azure.com}"

log "Fetching Azure DevOps work item $id ($org/$project)"
json="$("$HELPERS/ado_fetch_workitem.sh" "$org" "$project" "$id" "$base")"

payload="$(echo "$json" | "$HELPERS/ado_extract_fields.sh")"
title="$(echo "$payload" | jq -r '.title')"
desc="$(echo "$payload" | jq -r '.description')"
wtype="$(echo "$payload" | jq -r '.type')"
state="$(echo "$payload" | jq -r '.state')"
tags="$(echo "$payload" | jq -r '.tags')"
ac="$(echo "$payload" | jq -r '.acceptance_criteria')"

# Create deterministic input text for openspec generate
task="$(cat <<EOF
Azure DevOps Work Item: $id
Type: $wtype
State: $state
Tags: $tags

Title:
$title

Description:
$desc

Acceptance Criteria:
$ac
EOF
)"

log "Generating spec from ADO work item"
spec_name="$("$DIR/spec_from_input.sh" "$task")"

log "DONE spec_from_ado → $spec_name (from ADO $id)"
echo "$spec_name"

#!/usr/bin/env bash
set -euo pipefail

# Usage: ado_fetch_workitem.sh <org> <project> <id> [base_url]
org="${1:?org required}"
project="${2:?project required}"
id="${3:?id required}"
base_url="${4:-https://dev.azure.com}"

: "${AZURE_DEVOPS_PAT:?AZURE_DEVOPS_PAT missing}"

url="$base_url/$org/$project/_apis/wit/workitems/$id?api-version=7.0"

curl -fsS \
  -u ":$AZURE_DEVOPS_PAT" \
  -H "Accept: application/json" \
  "$url"

#!/usr/bin/env bash
set -euo pipefail

# Reads ADO work item JSON from stdin
# Optionally loads comments if ADO_COMMENTS_URL + PAT are available

TMP_JSON=$(mktemp)
cat > "$TMP_JSON"

WORKITEM_ID=$(jq -r '.id' "$TMP_JSON")
WORKITEM_TYPE=$(jq -r '.fields."System.WorkItemType" // ""' "$TMP_JSON")

# ------------------------------------------------
# HTML → Plaintext helper
# ------------------------------------------------
html_to_text() {
  sed -E '
    s/<br[[:space:]]*\/?>/\n/gI;
    s/<\/p>/\n/gI;
    s/<li>/ - /gI;
    s/<[^>]+>//g;
    s/&nbsp;/ /g;
    s/&amp;/\&/g;
  '
}

# ------------------------------------------------
# Base Fields
# ------------------------------------------------
TITLE=$(jq -r '.fields."System.Title" // ""' "$TMP_JSON")
DESCRIPTION=$(jq -r '.fields."System.Description" // ""' "$TMP_JSON" | html_to_text)

TAGS=$(jq -r '.fields."System.Tags" // ""' "$TMP_JSON")
STATE=$(jq -r '.fields."System.State" // ""' "$TMP_JSON")

# ------------------------------------------------
# Acceptance Criteria (Multiple possible fields)
# ------------------------------------------------
AC_RAW=$(
  jq -r '
    .fields."Microsoft.VSTS.Common.AcceptanceCriteria"
    // .fields."Custom.AcceptanceCriteria"
    // ""
  ' "$TMP_JSON"
)

ACCEPTANCE_CRITERIA=$(echo "$AC_RAW" | html_to_text)

# ------------------------------------------------
# Repro Steps (Bug specific)
# ------------------------------------------------
REPRO_STEPS=""

if [[ "$WORKITEM_TYPE" == "Bug" ]]; then
  REPRO_RAW=$(
    jq -r '
      .fields."Microsoft.VSTS.TCM.ReproSteps"
      // .fields."Custom.ReproSteps"
      // ""
    ' "$TMP_JSON"
  )

  REPRO_STEPS=$(echo "$REPRO_RAW" | html_to_text)
fi

# ------------------------------------------------
# System Info (Bug specific)
# ------------------------------------------------
SYSTEM_INFO=""

if [[ "$WORKITEM_TYPE" == "Bug" ]]; then
  SYS_RAW=$(
    jq -r '
      .fields."Microsoft.VSTS.TCM.SystemInfo"
      // .fields."Custom.SystemInfo"
      // ""
    ' "$TMP_JSON"
  )

  SYSTEM_INFO=$(echo "$SYS_RAW" | html_to_text)
fi

# ------------------------------------------------
# Comments (Optional API Call)
# Requires:
#   AZURE_DEVOPS_PAT
#   ADO_COMMENTS_URL (full URL to comments endpoint)
# ------------------------------------------------
COMMENTS_JSON="[]"

if [[ -n "${ADO_COMMENTS_URL:-}" && -n "${AZURE_DEVOPS_PAT:-}" ]]; then
  COMMENTS_JSON=$(curl -s \
    -u ":$AZURE_DEVOPS_PAT" \
    "$ADO_COMMENTS_URL" \
    | jq '[.comments[] | {
        author: .createdBy.displayName,
        created: .createdDate,
        text: (.text | gsub("<[^>]+>"; ""))
      }]')
fi

# ------------------------------------------------
# Final JSON Output
# ------------------------------------------------
jq -n \
  --arg id "$WORKITEM_ID" \
  --arg type "$WORKITEM_TYPE" \
  --arg title "$TITLE" \
  --arg desc "$DESCRIPTION" \
  --arg tags "$TAGS" \
  --arg state "$STATE" \
  --arg ac "$ACCEPTANCE_CRITERIA" \
  --arg repro "$REPRO_STEPS" \
  --arg sys "$SYSTEM_INFO" \
  --argjson comments "$COMMENTS_JSON" \
'
{
  id: $id,
  type: $type,
  title: $title,
  description: $desc,
  tags: $tags,
  state: $state,
  acceptance_criteria: $ac,
  repro_steps: $repro,
  system_info: $sys,
  comments: $comments
}
'

rm "$TMP_JSON"

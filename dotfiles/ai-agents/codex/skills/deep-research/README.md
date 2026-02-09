# Deep research (lean)

## Requirements
- bash
- jq

## Usage
.codex/skills/deep-research/scripts/run_research.sh "Research goal..."

Produces:
.research/<run-id>/{sources.md,notes.md,requirements.json}

Then:
.codex/skills/openspec/scripts/spec_from_input.sh .research/<run-id>/requirements.json

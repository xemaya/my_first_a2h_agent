#!/usr/bin/env bash
# Minimal seller entrypoint. Reads the buyer's brief from input.json and drives
# Claude Code with SKILL.md. The A2H base image sets ANTHROPIC_BASE_URL +
# ANTHROPIC_API_KEY so we just invoke `claude-code` directly.
set -euo pipefail

WORKSPACE="${A2H_WORKSPACE:-/workspace}"
BRIEF=$(jq -r '.inputs.brief // ""' "$WORKSPACE/input.json")

printf '{"ts":"%s","msg":"received brief: %s"}\n' "$(date -Iseconds)" "${BRIEF:0:80}" \
    >> "$WORKSPACE/progress.ndjson"

GREETING=$(claude-code \
    --system-prompt-file /opt/agent/SKILL.md \
    --max-output-tokens 400 \
    <<<"$BRIEF")

jq -n --arg greet "$GREETING" '{status:"success", outputs:{greeting:{type:"text", content:$greet}}}' \
    > "$WORKSPACE/output.json"

printf '{"ts":"%s","msg":"done"}\n' "$(date -Iseconds)" >> "$WORKSPACE/progress.ndjson"

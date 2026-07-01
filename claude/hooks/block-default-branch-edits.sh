#!/usr/bin/env bash
# PreToolUse hook: block Edit/Write/NotebookEdit on the default branch
# (main/master) so changes always land on a feature branch first.

file_path=$(jq -r '.tool_input.file_path // empty')
dir=$(dirname "$file_path" 2>/dev/null)
[ -d "$dir" ] || dir="$PWD"

# symbolic-ref reports the branch even before the first commit (unborn branch),
# unlike `rev-parse --abbrev-ref HEAD` which returns "HEAD".
branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null)

case "$branch" in
  main | master)
    cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"You are on the default branch. Create a new branch first with git switch -c <name>, then retry."}}
JSON
    ;;
esac

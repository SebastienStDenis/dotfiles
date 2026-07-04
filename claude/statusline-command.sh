#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
dir_name=$(basename "$cwd")

DIM='\033[2m'
RESET='\033[0m'

git_branch=""
dir_display="$dir_name"
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    status_porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    staged=false
    unstaged=false
    untracked=false
    while IFS= read -r status_line; do
      [ -z "$status_line" ] && continue
      [[ "$status_line" == \?\?* ]] && untracked=true
      x=${status_line:0:1}
      y=${status_line:1:1}
      [[ "$x" != " " && "$x" != "?" ]] && staged=true
      [[ "$y" != " " && "$y" != "?" ]] && unstaged=true
    done <<< "$status_porcelain"

    dots=""
    $staged && dots="${dots}●"
    $unstaged && dots="${dots}${DIM}●${RESET}"
    $untracked && dots="${dots}○"

    repo_path=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    [ -z "$repo_path" ] && repo_path="$cwd"
    encoded_repo=$(printf '%s' "$repo_path" | jq -sRr '@uri | gsub("%2F"; "/")')
    link_url="cursor://file${encoded_repo}/"

    dir_display="\033]8;;${link_url}\a${dir_name}\033]8;;\a"
    git_branch=" [${branch}${dots}]"
  fi
fi

make_bar() {
  local pct=$1 width=10
  local filled=$(( (pct * width + 50) / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  local empty=$((width - filled))
  local bar="" i
  for ((i = 0; i < filled; i++)); do bar+="▓"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  printf '%s' "$bar"
}

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

parts=()

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  parts+=("ctx $(make_bar "$used_int") ${used_int}%")
fi

if [ -n "$five" ]; then
  five_int=$(printf '%.0f' "$five")
  parts+=("5h $(make_bar "$five_int") ${five_int}%")
fi

if [ -n "$week" ]; then
  week_int=$(printf '%.0f' "$week")
  parts+=("7d $(make_bar "$week_int") ${week_int}%")
fi

if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  parts+=("$(printf '$%.2f' "$cost")")
fi

line="${dir_display}${git_branch} ${DIM}|${RESET} ${model}"

for p in "${parts[@]}"; do
  line="${line} ${DIM}|${RESET} ${p}"
done

printf "%b\n" "$line"

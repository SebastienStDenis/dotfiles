#!/usr/bin/env bash

export LC_ALL=C

command -v jq > /dev/null 2>&1 || exit 0

input=$(cat)

IFS=$'\t' read -r cwd model used five cost duration < <(
  jq -r '[
    .workspace.current_dir,
    .model.display_name,
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.cost.total_cost_usd // ""),
    (.cost.total_duration_ms // "")
  ] | @tsv' <<< "$input"
)

truncate_middle() {
  local s=$1 max=$2
  (( ${#s} <= max )) && { printf '%s' "$s"; return; }
  local head=$(( max / 2 ))
  local tail=$(( max - 1 - head ))
  printf '%s…%s' "${s:0:head}" "${s: -tail}"
}

dir_name=$(truncate_middle "$(basename "$cwd")" 20)

DIM=$'\033[2m'
RESET=$'\033[0m'
OSC8=$'\033]8;;'
ST=$'\a'

git_branch=""
dir_display="$dir_name"
repo_path=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
if [ -n "$repo_path" ]; then
  encoded_repo=$(printf '%s' "$repo_path" | jq -sRr '@uri | gsub("%2F"; "/")')
  dir_display="${OSC8}cursor://file${encoded_repo}/${ST}${dir_name}${OSC8}${ST}"

  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -n "$branch" ] || branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  branch=$(truncate_middle "$branch" 28)
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

parts=()

add_pct() {
  local label=$1 pct=$2
  [ -n "$pct" ] || return 0
  local n
  n=$(printf '%.0f' "$pct")
  parts+=("$label $(make_bar "$n") ${n}%")
}

add_pct "ctx" "$used"
add_pct "5h" "$five"

if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  parts+=("$(printf '$%.2f' "$cost")")
fi

if [ -n "$duration" ]; then
  total_s=$(( ${duration%.*} / 1000 ))
  if (( total_s >= 3600 )); then
    parts+=("$(( total_s / 3600 ))h $(( total_s % 3600 / 60 ))m")
  elif (( total_s >= 60 )); then
    parts+=("$(( total_s / 60 ))m")
  else
    parts+=("${total_s}s")
  fi
fi

line="${dir_display}${git_branch} ${DIM}|${RESET} ${model}"

for p in "${parts[@]}"; do
  line="${line} ${DIM}|${RESET} ${p}"
done

printf '%s\n' "$line"

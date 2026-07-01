---
description: Rebase, validate, push, and create a PR with user checkpoints at every destructive step.
allowed-tools: Bash, Read
---

# pr-create

Automate the full workflow of rebasing, validating, pushing, and opening a GitHub PR.

## Steps

Run these steps in order. Each step lists its own stop/failure behavior; do not treat every non-zero exit as fatal (some, like `gh pr view` when no PR exists, are expected).

### 1. Preflight checks

Detect the default branch name (main, master, etc):
```
git remote show origin | sed -n 's/.*HEAD branch: //p'
```
Remember this value - every later step that references `<default-branch>` must substitute it, not prompt the user and not hardcode `main`.

If the current branch IS the default branch, create a new feature branch to hold this work and switch to it. Determine a good branch name yourself:
```
git status --porcelain
git diff HEAD
```
Then create and switch to it:
```
git switch -c <derived-branch-name>
```
Tell the user which branch you created and why. From this point on, `<current-branch>` refers to this new branch, and the rest of the workflow proceeds unchanged.

Confirm `gh` CLI is installed and authenticated (`gh auth status`). If not, stop and tell the user.

### 2. Capture uncommitted work

Commit any uncommitted changes to tracked files automatically - the user expects the workflow to pick up local work:
```
git add -u
git diff --cached --quiet || git commit -m "wip: uncommitted changes"
```
The `git diff --cached --quiet` guard makes this a no-op when there's nothing staged.

If there are untracked files, list them and ask the user individually which (if any) to include. Do not run `git add -A` - it sweeps in scratch files, `.env`, editor swap files, and anything the user deliberately left untracked.

### 3. Rebase onto the latest default branch

Before rebasing, check whether the branch is already pushed and potentially shared:
```
git rev-parse --verify --quiet origin/<current-branch>
```
If the remote branch exists, warn the user that rebasing will require a force-push and ask whether to proceed. If anyone else might have based work on this branch, stop.

Then:
```
git fetch origin <default-branch>
git rebase origin/<default-branch>
```

If the rebase hits conflicts, **stop immediately**. Tell the user there are conflicts they need to resolve manually, and show them the conflicting files. Do not attempt to resolve conflicts.

### 4. Validate

Detect the repo's build system and run all available validation steps: lint, typecheck, tests, build, and whatever else is applicable. Run them sequentially and report results for each.

If any check fails, report which ones and ask the user whether to abort. If they want to push despite failures, require them to type `skip validation` verbatim as confirmation - a plain "yes" is not enough. Do NOT continue to push automatically.

### 5. Push the branch

A rebase rewrites history, so if the branch was already pushed a plain `git push` will be rejected. Use:
```
git push --force-with-lease --force-if-includes
```
Never use a bare `git push --force` - it will clobber remote changes you haven't seen. If `--force-with-lease` is itself rejected, stop and report to the user; do not escalate to `--force`.

### 6. Open the PR

Surface a GitHub link for the user to create the PR, or the existing PR if one already exists for this branch. Do not launch a browser.

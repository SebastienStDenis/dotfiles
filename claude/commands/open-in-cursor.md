---
description: Open the current git worktree/branch in Cursor
allowed-tools: Bash
---

# open-in-cursor

Open the current git worktree (the branch you're on) in the Cursor editor.

## Steps

1. Resolve the root of the current worktree:
   ```
   git rev-parse --show-toplevel
   ```
   If this fails (not a git repo), stop and tell the user.

2. Open that directory in Cursor:
   ```
   cursor "$(git rev-parse --show-toplevel)"
   ```
   This opens the worktree checked out to the current branch. Cursor reuses an
   existing window for the same folder or opens a new one.

3. Confirm to the user which branch/worktree was opened:
   ```
   git rev-parse --abbrev-ref HEAD
   ```

If `cursor` is not on `PATH`, tell the user to run "Shell Command: Install 'cursor' command"
from Cursor's command palette, then retry.

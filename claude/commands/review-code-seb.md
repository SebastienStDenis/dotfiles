---
description: Review code with the code-reviewer-seb agent (optional scope — files, commit range, or branch)
---

Delegate to the `code-reviewer-seb` agent using the Task tool with `subagent_type: code-reviewer-seb`. Pass the scope below, clean it up if necessary.

If the scope is empty, use AskUserQuestion to ask the user what to review (e.g., uncommitted changes, a commit or commit range, a branch vs. main, specific files) before delegating. Do not guess a default.

Scope: $ARGUMENTS

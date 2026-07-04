---
description: Generate tests with the test-generator-seb agent (optional scope — files, modules, or commits)
---

Delegate to the `test-generator-seb` agent using the Task tool with `subagent_type: test-generator-seb`. Pass the scope below, clean it up if necessary.

If the scope is empty, use AskUserQuestion to ask the user what to test (e.g., specific files or modules, uncommitted changes, a commit or commit range, a branch vs. main) before delegating. Do not guess a default.

Scope: $ARGUMENTS

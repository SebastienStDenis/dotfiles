# Pull request prompt

> Draft a pull request title and summary for the full branch delta.
>
> Context:
> - branch: `<branch>`
> - base commit: `<base>`
> - target commit: `<head>`
> - default branch: `<default>`
>
> Rules:
> - Cover the full branch delta, not just the latest commit.
> - Title must use conventional commit format: "type(scope): description" or "type: description". Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert. Scope is optional. Do not capitalize the type. Do not use the raw branch name.
> - If the change has any user-facing product impact, the type must use feat or fix so release automation can pick it up. Use feat for a new user-visible capability and fix for a user-visible correction or behavior improvement. Use docs, refactor, chore, test, build, or ci only when the change has no user-facing product behavior impact.
> - When including a scope, it MUST be a real package/module name that exists in the codebase (for example, a directory under internal/, cmd/, or the equivalent top-level grouping for this project), identified by inspecting the changed paths. Pick the primary module affected by the change, not a secondary or incidental one.
> - Keep the scope at a coarse level, not too granular: a codebase typically has fewer than 10 distinct scopes in use across its history. Prefer a broad module name (e.g. "daemon", "pipeline", "cli") over a narrow file or sub-feature name. If you cannot confidently identify a real primary module, omit the scope and use "type: description".
> - Body: a "## What Changed" section in GitHub-flavored markdown. 1-3 concise bullet points describing the concrete changes in this branch (what code/behavior shifted), not the user's motivation. The body value must be plain markdown text, never a JSON object or serialized JSON string.
> - Do not invent tests or behavior.
>
> Commit history:
> `<git log base..head>`
>
> Diff stat:
> `<git diff --stat base..head>`
>
> User intent for this change:
> `<intent>`

# Rebase prompt

Used only when a rebase stops on merge conflicts (SKILL.md step 1).

> Resolve git rebase conflicts. The rebase of the current branch onto `<target>` has conflicts.
>
> Current conflicted files:
> - `<conflicted files>`
>
> Instructions:
> - Find all conflicting files and resolve the conflict markers (`<<<<<<<` `=======` `>>>>>>>`).
> - After resolving each file, stage it with: `git add <file>`
> - After all conflicts are resolved, run: `git rebase --continue`
> - If additional conflicts arise during `rebase --continue`, resolve those too.
> - Do not modify any files that don't have conflicts.
> - Preserve the intent of both the current branch changes and the upstream changes.
> - Return JSON with a single "summary" field describing what you resolved.
> - Keep the summary under 10 words.
>
> User intent for this change:
> `<intent>`

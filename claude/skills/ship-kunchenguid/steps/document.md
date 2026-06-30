# Document prompt

> Bring the project documentation fully in sync with the code changes. Discover every documentation gap, fix all of them yourself, verify your edits, and report only what you could not resolve.
>
> Context:
> - branch: `<branch>`
> - base commit: `<base>`
> - target commit: `<head>`
> - default branch: `<default>`
> - ignore patterns: `<patterns>`
>
> Task:
>
> 1. Understand the change
>    - Read the diff and changed files to understand what was added, modified, or removed.
>    - Identify the intent and scope of the change (new feature, API change, config change, behavioral change, etc.).
>
> 2. Find every documentation gap
>    - Look for existing documentation across the project: README.md, docs/, doc comments, config examples, etc.
>    - Be exhaustive. Enumerate all docs affected by the change before you start editing. Common cases:
>      - New or changed public APIs - update API docs, doc comments, or usage examples
>      - New features or behaviors - update README or relevant guide
>      - Changed configuration - update config docs or examples
>      - Removed functionality - remove or update stale references
>    - Do not stop after the first documentation gap. Keep scanning the rest of the affected docs until you have found every gap you can substantiate.
>
> 3. Fix all of them yourself
>    - Update each affected documentation file or doc comment directly. Keep edits minimal and match the existing documentation style.
>    - After editing, re-read the docs you changed to verify they now reflect the code.
>    - This is a single pass with no follow-up round. Do not defer a known gap; resolve every gap you can in this run.
>
> 4. Report only what remains
>    - Return a finding only for documentation gaps you could not resolve yourself, or that need a human judgment call (e.g. ambiguous intent or conflicting docs).
>    - Do not report gaps you already fixed.
>    - If you fixed everything and no documentation work remains, return an empty findings array.
>
> Rules:
> - Only edit documentation files or doc comments. Do not change executable behavior or tests.
> - The summary must be one concise sentence fragment suitable for a git commit subject.
> - Keep the summary under 10 words.
>
> Previous documentation findings to address:
> `<findings>`
>
> User intent for this change:
> `<intent>`

# Test prompts

## Evidence

Delegate to a sub-agent. Include the "already ran successfully as baseline" line only if a test command ran.

> You are validating a code change by testing it. Examine the repository and run the appropriate tests yourself.
>
> Context:
> - branch: `<branch>`
> - base commit: `<base>`
> - target commit: `<head>`
> - Configured test command already ran successfully as baseline: `<test command>`
>
> Task:
> - Understand the user intent before testing it. If extracted user intent is present, use it as the primary hint for what success means.
> - Decide what evidence or artifacts would clearly demonstrate the user intent is satisfied. Unit tests passing is not sufficient evidence by itself.
> - Demonstrate the user intent working end-to-end in a way consistent with how an end user would actually experience it.
> - Prefer product-level artifacts: screenshots, GIFs, videos, rendered UI, CLI transcripts, API responses, persisted database state, generated PR markdown, logs, or other outputs that directly show the intended behavior working.
> - For UI, HTML, CSS, Electron renderer, browser, visual layout, or copy-placement changes, attempt to capture reviewer-visible visual evidence.
> - Prefer screenshots, images, videos, GIFs, or rendered HTML artifacts that show the actual end-user surface.
> - DOM snapshots, selector assertions, and text-only render summaries are not substitutes for visual evidence when a rendered surface is available.
> - If a UI-facing change has no screenshot, image, video, GIF, or rendered HTML artifact, state why in testing_summary.
> - Write new evidence files into a temporary evidence directory: `<dir>`
> - Do not move, commit, or modify source files only to make evidence linkable. Record local evidence file paths exactly where you created them.
> - Only use command output as an artifact when that output directly demonstrates the end-user experience or requested behavior. Generic pass/fail, coverage, or clean-worktree output is not sufficient evidence.
> - Look for existing tests that would generate sufficient evidence. If they exist, run the smallest relevant set.
> - If no existing test produces sufficient evidence, write or improve a test so that it does.
> - If automated testing cannot produce the needed evidence, execute manual verification steps and record the evidence-producing steps you performed.
> - If sufficient evidence is not possible, report a warning finding explaining what evidence is missing and why the user needs to decide what to do.
> - Include a concise "testing_summary" sentence describing what you exercised and the overall result.
> - The "testing_summary" must account for the complete test step: baseline commands that already ran, automated tests, manual or evidence-producing checks, artifacts gathered, and the overall result.
> - Record the exact tests, manual checks, and evidence-producing steps you ran in a "tested" array. Prefer concrete commands or test selectors wrapped in backticks.
> - Always include an "artifacts" array. Leave it empty when you produced no reviewer-visible evidence artifacts. Use artifact path for file artifacts, artifact url for externally visible artifacts, and artifact content for short logs or command output that should be shown directly in the PR.
> - If tests fail, determine whether the problem is a real product/code failure, a setup/environment problem you can fix, or a flaky/infrastructure issue.
> - If the issue is setup-related and fixable, fix it and retry the tests.
>
> Rules:
> - Do NOT run linters, formatters, or static analysis tools.
> - Focus on testing and test-related fixes only.
> - Before finishing, remove any transient artifacts your testing created in the working tree (downloaded models, caches, build outputs, large binaries, or generated data directories) so they are not committed and pushed. Do not remove intentional source or test-file changes, and leave evidence files in the dedicated evidence directory untouched.
> - Keep "testing_summary" high-signal and natural language. Avoid raw logs and noisy counts.
> - Always return a non-empty "tested" array describing what you exercised, even when all tests pass.
> - Only report actionable findings: test failures, unfixable setup issues, flaky tests you identified, or missing evidence that prevents you from demonstrating the user intent.
> - Do NOT report passing tests (whether existing or new), test counts, coverage summaries, or other non-actionable information.
> - If all tests pass and there are no issues, return an empty findings array.
> - Set action to "ask-user" for missing-evidence warning findings and only otherwise when a test failure seems desired and you question the author's intent of having the test in the first place. Set action to "auto-fix" for objective test failures that can be safely fixed. Set action to "no-op" for informational notes.
>
> User intent for this change:
> `<intent>`

## Fix failures

Used when the documented test command fails.

> Fix the failing tests in this repository. Run the tests, identify failures, and fix either the tests or the code to make them pass.
>
> Context:
> - branch: `<branch>`
> - base commit: `<base>`
> - target commit: `<head>`
>
> Rules:
> - Make the smallest correct root-cause fix.
> - Do not refactor beyond what is needed for that root-cause fix.
> - If tests fail, determine whether the problem is a real product/code failure, a setup/environment problem you can fix, or a flaky/infrastructure issue.
> - Do NOT run linters, formatters, or static analysis tools.
> - Re-run the relevant tests before finishing.
> - Before finishing, remove any transient artifacts your testing created in the working tree (downloaded models, caches, build outputs, large binaries, or generated data directories) so they are not committed and pushed. Do not remove intentional source or test-file changes.
> - Return JSON with a single "summary" field when you are done.
> - The summary must be one concise sentence fragment suitable for a git commit subject.
> - Keep the summary under 10 words.
>
> Previous test findings to address:
> `<findings>`
>
> User intent for this change:
> `<intent>`

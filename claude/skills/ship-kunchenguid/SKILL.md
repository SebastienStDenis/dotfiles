---
name: ship-kunchenguid
description: Validate the committed work on your current branch through a fixed pipeline - rebase, code review, tests, docs, lint - then push and open a clean PR, landing every fix as an additional commit. Use when the user asks to ship, gate, or validate their changes, or invokes /ship-kunchenguid.
user-invocable: true
---

# ship-kunchenguid

`/ship-kunchenguid` validates the committed work on your current branch through a fixed pipeline - rebase, review, test, document, lint - then pushes the branch and opens a pull request. The pipeline runs in place on your branch. Every fix or tweak made along the way lands as an additional commit; your original commits are only ever rewritten by the rebase.

This file is the orchestrator: it runs the steps, decides what to delegate, and handles findings. The agent prompts for each step are kept verbatim in `steps/<step>.md`; read the named block and use it as directed below. Report the outcome at the end. If the user asks for something specific - for example "skip the lint step" - honor it.

## Before you start

- You must be on a feature branch, not the repository's default branch.
- The work being validated must be committed. If the working tree has uncommitted changes, stage and commit them first with a concise auto-generated commit subject (see [Committing](#committing)) so everything is committed before the pipeline runs.
- Compute these once, up front, and use them to fill the `<...>` placeholders in the step prompts:
  - `<default>` = the repository's default branch (`origin/HEAD`, else `main`)
  - `<branch>` = the current branch
  - `<base>` = `git merge-base HEAD origin/<default>`
  - `<head>` = `HEAD`
  - `<intent>` = what the user set out to accomplish (see [Intent is required](#intent-is-required))
  - `<patterns>` = generated/vendored/lockfile paths to skip in review and docs, or `none`
- Test, lint, and format commands are the project's own documented commands (`CLAUDE.md`, `Makefile`, `package.json`, etc.); detect them yourself when none is documented.

## Intent is required

You must know the **intent**: what the user set out to accomplish - the goal or request behind this work, in their terms. This is not a description of the diff or the files changed; it is the objective the change is meant to achieve. You know it from the conversation, so use it directly.

Err on the side of completeness, not brevity. The review step uses the intent to tell a deliberate decision apart from a mistake, so a thin one-line summary makes it flag things the user already chose. Capture the nuance: the user's goal, the specific decisions and tradeoffs made along the way, any constraints or approaches ruled in or out, and anything explicitly asked for that might otherwise look surprising in the diff. A few sentences to a short paragraph is normal.

## Using the prompts

Each step's prompt lives in `steps/<step>.md` as a verbatim block. To use one, take the block, replace its `<...>` placeholders with the values above (and `<findings>` with the relevant findings when re-running after a fix), and either follow it yourself (inline steps) or hand it to a sub-agent (delegated steps). Do not add your own framing to the prompt - the prompt is the prompt.

**Delegated steps.** Review and Test run as a fresh sub-agent, so they get an independent context: review does not rubber-stamp code written in this session, and the test step's noisy output stays out of yours. To delegate, spawn a sub-agent, give it the filled prompt block plus the working directory, and let it work in the same tree (its edits and commits persist). It returns findings or a summary; you handle them per [Handling findings](#handling-findings). A sub-agent never decides an `ask-user` finding - it returns those for you to escalate.

## The pipeline

Run in order. Cheap judgment first; nothing pushes until everything is green.

### 1. Rebase (inline)

- Fetch the default branch (`git fetch origin <default>`) and rebase the current branch onto `origin/<default>`. Skip if already up to date or ahead; fast-forward if the branch is only behind.
- If the rebase stops on conflicts, resolve them with the prompt in `steps/rebase.md` (its `<target>` is `origin/<default>`), then `git rebase --continue`.
- The rebase rewrites commit SHAs, so the push in step 6 must use `--force-with-lease`.

### 2. Review (delegated; find then fix)

- If there are no changed files left after applying `<patterns>`, skip this step.
- Delegate the **Find** prompt (`steps/review.md`) to a fresh reviewer sub-agent. It returns findings and a risk level, and fixes nothing.
- Handle the findings per [Handling findings](#handling-findings): fix each `auto-fix` finding (and any `ask-user` finding the user told you to fix) yourself using the **Fix** prompt (`steps/review.md`), ignore `no-op`, escalate `ask-user`. Commit the fixes (see [Committing](#committing)), then re-run the Find prompt on the current state to confirm they are resolved.

### 3. Test (delegated)

- If the project has a documented test command, run it first as the deterministic baseline. If it exits non-zero, fix it with the **Fix failures** prompt (`steps/test.md`) and re-run. A passing command does not end the step on its own.
- Then delegate the **Evidence** prompt (`steps/test.md`) to a sub-agent, having it write evidence into a temporary directory you create and pass as `<dir>`. Include the prompt's "already ran successfully as baseline" line only if a test command ran.
- The sub-agent fixes objective failures and commits them, and returns a summary plus any `ask-user` findings (e.g. missing evidence) for you to escalate.

### 4. Document (inline)

- If nothing that warrants documentation changed (after applying `<patterns>`), skip this step.
- Follow the prompt in `steps/document.md`, then commit any documentation edits (see [Committing](#committing)). It reports only unresolved gaps; treat a gap needing a human call as `ask-user`.

### 5. Lint and format (inline)

- If the project has a documented lint command, run it; on failure fix with the **Fix** prompt (`steps/lint.md`) and re-run.
- If the project has a documented format command, run it before committing.
- If no lint command is documented, follow the **Detect-and-fix** prompt (`steps/lint.md`).
- Commit any fixes (see [Committing](#committing)).

### 6. Push and PR (inline)

- Make sure all fixes are committed. Push with `git push --force-with-lease`. If the push is rejected because the remote moved out from under you, STOP and ask the user - never a bare `--force`, never retry harder. (A brand-new branch with no remote is a plain push.)
- Open or update the PR with `gh pr create` / `gh pr edit`, using the prompt in `steps/pr.md`. Skip PR creation if the branch is the default branch.

## Handling findings

Each finding has a severity (`error`, `warning`, `info`), a file and line where possible, a description, and an `action` that classifies it:

- **auto-fix** - the finding is a non-functional, non user-visible issue (correctness, error handling, security, performance, mechanical code quality) that can be safely fixed without any discussion about the author's intent. Fix it directly.
- **no-op** - the finding is informational and does not require any action (e.g. noting a pattern, acknowledging a tradeoff). Nothing to do.
- **ask-user** - the finding is about functional requirements or product behavior, or otherwise challenges the author's deliberate intent. This is a call only the user can make. Stop and escalate it before doing anything.

To escalate an `ask-user` finding, relay it to the user as written - its file, line, and full description, verbatim. Do not paraphrase, summarize away the detail, or pre-judge the answer. Ask how they want to proceed, then act on their decision: fix it (with their guidance), accept it as-is, or skip it.

The one exception is explicit standing consent to drive the whole run unattended (for example the user says "just ship it" or passes `-y`): then resolve `ask-user` findings yourself like `auto-fix` ones.

## Committing

Land each step's fixes as their own commit. Use a concise commit subject - one sentence fragment, suitable for a git commit subject, under 10 words (for example `fix nil deref in run loop`, `update README for --json flag`). Do not rewrite the user's original commits; only the rebase changes their base. Add fixes and tweaks as additional commits stacked on top.

## After the PR

Once the branch is pushed and the PR is open you are done driving the pipeline. Tell the user the PR is ready and ask them to review and merge it; include the PR link. Do not wait for the merge. If they want to watch CI, `gh pr checks --watch` shows the status.

Summarize what happened: what was validated and what was found. If you applied fixes the original change missed, list each one so the user can review them.

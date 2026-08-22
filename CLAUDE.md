# CLAUDE.md

## What this is

Dotfiles for macOS and Linux, managed by a single Makefile. Each top-level directory holds one tool's config (`brew/`, `claude/`, `cursor/`, `git/`, `iterm2/`, `opencode/`, `rcmd/`, `zsh/`), plus `agents/` for the instructions shared across coding agents, and `link-*` targets symlink those files into `$HOME`. macOS gets the full setup; Linux gets git, zsh, and Claude. There is no build, lint, or test suite; verification is running the relevant make target (or `make -n <target>` to dry-run).

## Commands

- `make help` - list all targets with descriptions
- `make bootstrap-mac` - full macOS setup: Homebrew, packages, git, Oh My Zsh, iTerm2, Cursor, Claude, Codex, opencode
- `make bootstrap-linux` - Linux setup: git, Oh My Zsh, and Claude
- `make <tool>-setup` - set up one tool (e.g. `claude-setup`, `cursor-setup`)
- `make link-<tool>` - just create the symlinks for one tool
- `make dump` - regenerate `brew/.Brewfile` and `cursor/extensions.txt` from the current machine

## Architecture

- **Symlinks, not copies.** The `backup_and_link` macro in the Makefile links repo files into `$HOME`, backing up any pre-existing real file with a timestamp suffix. A symlink already pointing at the repo file is replaced silently, which keeps the targets idempotent; a symlink pointing anywhere else aborts the target, since it belongs to something this repo didn't create and deleting it would lose the only record of where it pointed. Move the repo and the link targets will fail until the stale links are removed by hand. Once linked, editing a file in this repo immediately changes the live config on the machine.
- **Two-way flow.** Setup targets push config out to the machine; dump targets (`brew-dump`, `cursor-dump`) pull machine state back into the repo. `brew/.Brewfile` and `cursor/extensions.txt` are generated files - hand edits survive until the next `make dump` overwrites them, so prefer installing/uninstalling for real and dumping.
- **`agents/AGENTS.md` is the one set of agent instructions**, symlinked to `~/AGENTS.md`. Each agent's own global file points at it rather than repeating it: `claude/CLAUDE.md` is a single `@~/AGENTS.md` import, `opencode/opencode.jsonc` lists it under `instructions`, and Codex - which has no import syntax - gets `~/.codex/AGENTS.md` symlinked straight to the shared file. Tool-specific rules go in the pointer file; anything that applies everywhere goes in `agents/AGENTS.md`.
- **`claude/` is the user's global Claude Code config**, symlinked to `~/.claude/` (CLAUDE.md, settings.json, hooks/, agents/, commands/, skills/). Changes here affect every Claude Code session on the machine, including this one. `claude-setup` also installs the plugins declared in `claude/settings.json`.
- **The GitHub MCP token comes from `gh`**: `zsh/.zshrc` exports `GITHUB_PERSONAL_ACCESS_TOKEN` from `gh auth token`, which is the variable both Claude's github plugin and `opencode/opencode.jsonc` interpolate into their `Authorization` header. opencode pins `"oauth": false` on that server because its OAuth auto-detection fails against `api.githubcopilot.com` (no dynamic client registration), so the header is the only auth path.
- **iTerm2 is the exception**: no symlink; `iterm2-setup` uses `defaults write` to point iTerm2's custom prefs folder at `iterm2/` in this repo.
- **rcmd writes through its symlink**: the app saves settings changes to `rcmd/config.yaml` in this repo, so UI tweaks show up as uncommitted changes to review and commit. `overrideUserDefaults` stays `true` so the file is the source of truth: it is reapplied on every app launch and hand edits are picked up live, instead of GUI write-backs clobbering them with stale app state.
- The repo-local `.claude/settings.local.json` and `.claude/worktrees/` are gitignored; don't commit them.

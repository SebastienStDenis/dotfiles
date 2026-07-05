# CLAUDE.md

## What this is

Dotfiles for macOS and Linux, managed by a single Makefile. Each top-level directory holds one tool's config (`brew/`, `claude/`, `cursor/`, `git/`, `iterm2/`, `rcmd/`, `zsh/`), and `link-*` targets symlink those files into `$HOME`. macOS gets the full setup; Linux gets git, zsh, and Claude. There is no build, lint, or test suite; verification is running the relevant make target (or `make -n <target>` to dry-run).

## Commands

- `make help` - list all targets with descriptions
- `make bootstrap-mac` - full macOS setup: Homebrew, packages, git, Oh My Zsh, iTerm2, Cursor, Claude
- `make bootstrap-linux` - Linux setup: git, Oh My Zsh, and Claude
- `make <tool>-setup` - set up one tool (e.g. `claude-setup`, `cursor-setup`)
- `make link-<tool>` - just create the symlinks for one tool
- `make dump` - regenerate `brew/.Brewfile` and `cursor/extensions.txt` from the current machine

## Architecture

- **Symlinks, not copies.** The `backup_and_link` macro in the Makefile links repo files into `$HOME`, backing up any pre-existing non-symlink file with a timestamp suffix. Once linked, editing a file in this repo immediately changes the live config on the machine.
- **Two-way flow.** Setup targets push config out to the machine; dump targets (`brew-dump`, `cursor-dump`) pull machine state back into the repo. `brew/.Brewfile` and `cursor/extensions.txt` are generated files - hand edits survive until the next `make dump` overwrites them, so prefer installing/uninstalling for real and dumping.
- **`claude/` is the user's global Claude Code config**, symlinked to `~/.claude/` (CLAUDE.md, settings.json, hooks/, agents/, commands/, skills/). Changes here affect every Claude Code session on the machine, including this one. `claude-setup` also installs the plugins declared in `claude/settings.json`.
- **iTerm2 is the exception**: no symlink; `iterm2-setup` uses `defaults write` to point iTerm2's custom prefs folder at `iterm2/` in this repo.
- **rcmd writes through its symlink**: the app saves settings changes to `rcmd/config.yaml` in this repo, so UI tweaks show up as uncommitted changes to review and commit. `overrideUserDefaults` stays `false` so the app remains the source of truth.
- The repo-local `.claude/settings.local.json` and `.claude/worktrees/` are gitignored; don't commit them.

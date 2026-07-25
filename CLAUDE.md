# CLAUDE.md

## What this is

Dotfiles for macOS and Linux, managed by a single Makefile. Each top-level directory holds one tool's config (`brew/`, `claude/`, `cursor/`, `git/`, `iterm2/`, `linearmouse/`, `rcmd/`, `zsh/`), and `link-*` targets symlink those files into `$HOME`. macOS gets the full setup; Linux gets git, zsh, and Claude. There is no build, lint, or test suite; verification is running the relevant make target (or `make -n <target>` to dry-run).

## Commands

- `make help` - list all targets with descriptions
- `make bootstrap-mac` - full macOS setup: Homebrew, packages, git, Oh My Zsh, iTerm2, Cursor, Claude
- `make bootstrap-work` - macOS setup for an employer-owned machine (see below)
- `make bootstrap-linux` - Linux setup: git, Oh My Zsh, and Claude
- `make git-identity EMAIL="..."` - write this machine's git email to `~/.gitconfig.local`
- `make <tool>-setup` - set up one tool (e.g. `claude-setup`, `cursor-setup`)
- `make link-<tool>` - just create the symlinks for one tool
- `make dump` - regenerate `brew/.Brewfile` and `cursor/extensions.txt` from the current machine

## Architecture

- **Symlinks, not copies.** The `backup_and_link` macro in the Makefile links repo files into `$HOME`, backing up any pre-existing real file with a timestamp suffix. A symlink already pointing at the repo file is replaced silently, which keeps the targets idempotent; a symlink pointing anywhere else aborts the target, since it belongs to something this repo didn't create and deleting it would lose the only record of where it pointed. Move the repo and the link targets will fail until the stale links are removed by hand. Once linked, editing a file in this repo immediately changes the live config on the machine.
- **Two-way flow.** Setup targets push config out to the machine; dump targets (`brew-dump`, `cursor-dump`) pull machine state back into the repo. `brew/.Brewfile` and `cursor/extensions.txt` are generated files - hand edits survive until the next `make dump` overwrites them, so prefer installing/uninstalling for real and dumping.
- **`claude/` is the user's global Claude Code config**, symlinked to `~/.claude/` (CLAUDE.md, settings.json, hooks/, agents/, commands/, skills/). Changes here affect every Claude Code session on the machine, including this one. `claude-setup` also installs the plugins declared in `claude/settings.json`.
- **iTerm2 is the exception**: no symlink; `iterm2-setup` uses `defaults write` to point iTerm2's custom prefs folder at `iterm2/` in this repo.
- **rcmd writes through its symlink**: the app saves settings changes to `rcmd/config.yaml` in this repo, so UI tweaks show up as uncommitted changes to review and commit. `overrideUserDefaults` stays `true` so the file is the source of truth: it is reapplied on every app launch and hand edits are picked up live, instead of GUI write-backs clobbering them with stale app state.
- **LinearMouse writes through its symlink too**: the app resolves symlinks before saving, so settings changed in the UI land in `linearmouse/linearmouse.json` as uncommitted diffs, and edits to the repo file are picked up live.
- **The git email is per-machine.** `git/.gitconfig` keeps the name (same person everywhere) but no email; it includes `~/.gitconfig.local`, which `make git-identity` writes and which is never tracked here. `user.useConfigOnly = true` means a missing email fails the commit instead of being guessed from the hostname, so a work commit can't quietly go out under a personal address.
- **Work machines are marked, and the destructive targets refuse to run on them.** `make work-mode` (implied by `bootstrap-work`) drops a gitignored `.work-machine` file in the repo root. `brew-dump`, `brew-prune`, `cursor-dump`, `dump`, and `link-brew` abort when it exists: the dumps would copy an employer's installed software into this public repo, and `brew-prune` would uninstall anything IT installed that isn't in the Brewfile. Delete the file to override.
- **`bootstrap-work` deliberately skips the global Brewfile.** It installs from `brew/Brewfile.work` via `brew bundle --file` instead of linking `~/.Brewfile`, so `--global` commands have nothing to act on. `Brewfile.work` is hand-maintained (no dump target writes it) and holds every formula plus the casks that are neither personal nor likely to collide with employer provisioning or licensing.
- The repo-local `.claude/settings.local.json`, `.claude/worktrees/`, and `.work-machine` are gitignored; don't commit them.

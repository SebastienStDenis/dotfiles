# ── Config ─────────────────────────────────────────────────────────────
CURSOR_USER := $(HOME)/Library/Application Support/Cursor/User

BREW   := /opt/homebrew/bin/brew
BUNDLE := $(BREW) bundle --global

# Put brew-installed tools (cursor, claude, etc.) on PATH inside a recipe.
# No-op when Homebrew is absent (Linux).
SHELLENV := if [ -x "$(BREW)" ]; then eval "$$($(BREW) shellenv sh)"; fi

.PHONY: help \
        bootstrap-mac bootstrap-linux dump \
        brew-init brew-setup brew-install brew-dump brew-prune \
        git-setup omz-setup iterm2-setup cursor-setup cursor-dump claude-setup rcmd-setup \
        link-git link-zsh link-brew link-claude link-cursor link-rcmd

.DEFAULT_GOAL := help

# Link src -> dest, moving a real file at dest aside with a timestamp suffix.
# A symlink at dest is only replaced when it already points at src. Any other
# symlink belongs to something else - a second checkout, another tool - and
# removing it would destroy the only record of where it pointed.
define backup_and_link
	set -e; \
	src=$(1); dest=$(2); \
	if [ -L "$$dest" ]; then \
		current=$$(readlink "$$dest"); \
		if [ "$$current" != "$$src" ]; then \
			echo "$@: $$dest is a symlink to $$current, not $$src; remove it by hand to replace it" >&2; \
			exit 1; \
		fi; \
		rm "$$dest"; \
	elif [ -e "$$dest" ]; then \
		backup="$$dest.backup.$$(date +%Y%m%d%H%M%S)"; \
		mv "$$dest" "$$backup"; \
		echo "Backed up existing $$dest to $$backup"; \
	fi; \
	mkdir -p "$$(dirname "$$dest")"; \
	ln -s "$$src" "$$dest"; \
	echo "Linked $$dest to $$src"
endef

# Fail fast when a required tool is missing from PATH.
define require
	for tool in $(1); do \
		command -v "$$tool" >/dev/null 2>&1 || { echo "$@: $$tool is required but not on PATH" >&2; exit 1; }; \
	done
endef

# brew bundle hits transient network failures often enough to be worth a retry.
define bundle_retry
	for i in 1 2; do \
		$(1) && exit 0; \
		echo "brew bundle attempt $$i failed; retrying in 5s..." >&2; \
		sleep 5; \
	done; \
	$(1)
endef

# ── Help ───────────────────────────────────────────────────────────────
help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  %-15s %s\n", $$1, $$2}'

# ── Aggregates ─────────────────────────────────────────────────────────
bootstrap-mac: brew-setup brew-install git-setup omz-setup iterm2-setup cursor-setup claude-setup rcmd-setup ## Bootstrap the development environment on mac (backs up existing dotfiles)

bootstrap-linux: git-setup omz-setup claude-setup ## Bootstrap git, zsh, and Claude on linux (backs up existing dotfiles)

dump: brew-dump cursor-dump ## Run all dumps (brew-dump, cursor-dump)

# ── Homebrew ───────────────────────────────────────────────────────────
brew-init: ## Install Homebrew itself
	@[ -x "$(BREW)" ] || \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew-setup: brew-init link-brew ## Install Homebrew and link the global Brewfile

brew-install: ## Install packages from the global Brewfile (retries transient failures)
	@$(call bundle_retry,$(BUNDLE))

brew-dump: ## Overwrite Brewfile from current environment
	$(BUNDLE) dump --force --no-vscode

brew-prune: ## Remove packages not in Brewfile
	$(BUNDLE) cleanup --force --no-vscode

# ── Tools ──────────────────────────────────────────────────────────────
git-setup: link-git ## Configure git

omz-setup: link-zsh ## Install Oh My Zsh and plugins
	@$(call require,zsh)
	@[ -d "$(HOME)/.oh-my-zsh" ] || \
		RUNZSH=no KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] || \
		git clone https://github.com/zsh-users/zsh-autosuggestions "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] || \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

iterm2-setup: ## Configure iTerm2
	@pgrep -x iTerm2 >/dev/null 2>&1 && \
		echo "iterm2-setup: iTerm2 is running and may overwrite these prefs on quit; quit and relaunch it" >&2 || true
	/usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(CURDIR)/iterm2"
	/usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	killall cfprefsd || true

cursor-setup: link-cursor ## Link Cursor config and install extensions
	@$(SHELLENV); \
	while read -r ext; do \
		[ -z "$$ext" ] && continue; \
		cursor --install-extension "$$ext"; \
	done < "$(CURDIR)/cursor/extensions.txt"

cursor-dump: ## Overwrite Cursor extensions.txt from current environment
	$(SHELLENV) && cursor --list-extensions > "$(CURDIR)/cursor/extensions.txt"

rcmd-setup: link-rcmd ## Configure rcmd

claude-setup: link-claude ## Link Claude config and install plugins from settings.json
	@$(SHELLENV); \
	$(call require,claude); \
	jq -r '(.extraKnownMarketplaces // {})[].source.repo' "$(CURDIR)/claude/settings.json" | \
	while read -r repo; do \
		claude plugin marketplace add "$$repo" || true; \
	done; \
	jq -r '.enabledPlugins // {} | keys[]' "$(CURDIR)/claude/settings.json" | \
	while read -r plugin; do \
		claude plugin install "$$plugin" || true; \
	done

# ── Link helpers ───────────────────────────────────────────────────────
link-git: ## Link git dotfile
	@$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$(HOME)/.gitconfig")

link-zsh: ## Link zsh dotfile
	@$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$(HOME)/.zshrc")

link-brew: ## Link Brewfile
	@$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$(HOME)/.Brewfile")

link-claude: ## Link Claude CLAUDE.md, settings, scripts, hooks, agents, commands, and skills
	@$(call backup_and_link,"$(CURDIR)/claude/CLAUDE.md","$(HOME)/.claude/CLAUDE.md")
	@$(call backup_and_link,"$(CURDIR)/claude/settings.json","$(HOME)/.claude/settings.json")
	@$(call backup_and_link,"$(CURDIR)/claude/scripts","$(HOME)/.claude/scripts")
	@$(call backup_and_link,"$(CURDIR)/claude/hooks","$(HOME)/.claude/hooks")
	@$(call backup_and_link,"$(CURDIR)/claude/agents","$(HOME)/.claude/agents")
	@$(call backup_and_link,"$(CURDIR)/claude/commands","$(HOME)/.claude/commands")
	@$(call backup_and_link,"$(CURDIR)/claude/skills","$(HOME)/.claude/skills")

link-cursor: ## Link Cursor settings.json and keybindings.json
	@$(call backup_and_link,"$(CURDIR)/cursor/settings.json","$(CURSOR_USER)/settings.json")
	@$(call backup_and_link,"$(CURDIR)/cursor/keybindings.json","$(CURSOR_USER)/keybindings.json")

link-rcmd: ## Link rcmd config.yaml
	@$(call backup_and_link,"$(CURDIR)/rcmd/config.yaml","$(HOME)/.config/rcmd/config.yaml")

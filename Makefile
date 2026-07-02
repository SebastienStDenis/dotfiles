# ── Config ─────────────────────────────────────────────────────────────
CURSOR_USER := $(HOME)/Library/Application Support/Cursor/User
LOCAL_BIN   := $(HOME)/.local/bin

BUNDLEFLAGS := --global
BIN         := /opt/homebrew/bin
BREW        := $(BIN)/brew
BUNDLE      := $(BREW) bundle $(BUNDLEFLAGS)

# Put brew-installed tools (cursor, etc.) on PATH inside a recipe.
SHELLENV    := eval "$$($(BREW) shellenv sh)"

.PHONY: help \
        bootstrap-mac dump \
        brew-setup brew-install brew-dump brew-prune \
        git-setup omz-setup iterm2-setup cursor-setup cursor-dump claude-setup \
        link-git link-zsh link-brew link-claude link-cursor

.DEFAULT_GOAL := help

# Back up an existing dest (unless it's already a symlink), then link src -> dest.
define backup_and_link
	set -e; \
	src=$(1); dest=$(2); \
	if [ -L "$$dest" ]; then \
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

# ── Help ───────────────────────────────────────────────────────────────
help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  %-14s %s\n", $$1, $$2}'

# ── Aggregates ─────────────────────────────────────────────────────────
bootstrap-mac: brew-setup brew-install git-setup omz-setup iterm2-setup cursor-setup claude-setup ## Bootstrap the development environment on mac (backs up existing dotfiles)

dump: brew-dump cursor-dump ## Run all dumps (brew-dump, cursor-dump)

# ── Homebrew ───────────────────────────────────────────────────────────
brew-setup: link-brew ## Install Homebrew
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	grep -qs 'brew shellenv' $(HOME)/.zprofile || echo 'eval "$$($(BREW) shellenv)"' >> $(HOME)/.zprofile

brew-install: ## Install packages from Brewfile (retries transient failures)
	@$(SHELLENV); \
	for i in 1 2 3; do \
		$(BUNDLE) && exit 0; \
		echo "brew bundle attempt $$i failed; retrying in 5s..." >&2; \
		sleep 5; \
	done; \
	echo "brew bundle still failing after 3 attempts" >&2; \
	exit 1

brew-dump: ## Overwrite Brewfile from current environment
	$(SHELLENV) && $(BUNDLE) dump --force --no-vscode

brew-prune: ## Remove packages not in Brewfile
	$(SHELLENV) && $(BUNDLE) cleanup --force --no-vscode

# ── Tools ──────────────────────────────────────────────────────────────
git-setup: link-git ## Configure git

omz-setup: link-zsh ## Install Oh My Zsh and plugins
	@if [ ! -d "$(HOME)/.oh-my-zsh" ]; then \
		RUNZSH=no KEEP_ZSHRC=yes \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	else \
		echo "Oh My Zsh already installed, skipping"; \
	fi
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] || \
		git clone https://github.com/zsh-users/zsh-autosuggestions $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] || \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

iterm2-setup: ## Configure iTerm2
	/usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(CURDIR)/iterm2"
	/usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	killall cfprefsd || true

cursor-setup: link-cursor ## Link Cursor settings and install extensions
	@$(SHELLENV); \
	while read -r ext; do \
		[ -z "$$ext" ] && continue; \
		cursor --install-extension "$$ext"; \
	done < "$(CURDIR)/cursor/extensions.txt"

cursor-dump: ## Overwrite Cursor extensions.txt from current environment
	$(SHELLENV) && cursor --list-extensions > "$(CURDIR)/cursor/extensions.txt"

claude-setup: link-claude ## Install Claude Code, link config, and install enabled plugins
	curl -fsSL https://claude.ai/install.sh | bash
	@export PATH="$(LOCAL_BIN):$$PATH"; \
	python3 -c "import json; print('\n'.join(m['source']['repo'] for m in json.load(open('$(CURDIR)/claude/settings.json')).get('extraKnownMarketplaces', {}).values()))" | \
	while read -r repo; do \
		[ -z "$$repo" ] && continue; \
		claude plugin marketplace add "$$repo" || true; \
	done; \
	claude plugin marketplace update || true; \
	python3 -c "import json; print('\n'.join(json.load(open('$(CURDIR)/claude/settings.json')).get('enabledPlugins', {})))" | \
	while read -r plugin; do \
		[ -z "$$plugin" ] && continue; \
		claude plugin install "$$plugin" || true; \
	done

# ── Link helpers ───────────────────────────────────────────────────────
link-git: ## Link git dotfile
	@$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$(HOME)/.gitconfig")

link-zsh: ## Link zsh dotfile
	@$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$(HOME)/.zshrc")

link-brew: ## Link Brewfile
	@$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$(HOME)/.Brewfile")

link-claude: ## Link Claude CLAUDE.md, settings, hooks, agents, commands, and skills
	@$(call backup_and_link,"$(CURDIR)/claude/CLAUDE.md","$(HOME)/.claude/CLAUDE.md")
	@$(call backup_and_link,"$(CURDIR)/claude/settings.json","$(HOME)/.claude/settings.json")
	@$(call backup_and_link,"$(CURDIR)/claude/hooks","$(HOME)/.claude/hooks")
	@$(call backup_and_link,"$(CURDIR)/claude/agents","$(HOME)/.claude/agents")
	@$(call backup_and_link,"$(CURDIR)/claude/commands","$(HOME)/.claude/commands")
	@$(call backup_and_link,"$(CURDIR)/claude/skills","$(HOME)/.claude/skills")

link-cursor: ## Link Cursor settings.json
	@$(call backup_and_link,"$(CURDIR)/cursor/settings.json","$(CURSOR_USER)/settings.json")

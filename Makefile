# ── Config ─────────────────────────────────────────────────────────────
CURSOR_USER := $(HOME)/Library/Application Support/Cursor/User

BREW   := /opt/homebrew/bin/brew
BUNDLE := $(BREW) bundle --global

# Put brew-installed tools (cursor, claude, etc.) on PATH inside a recipe.
SHELLENV := eval "$$($(BREW) shellenv sh)"

.PHONY: help \
        bootstrap-mac bootstrap-linux dump \
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
		awk 'BEGIN{FS=":.*?## "}{printf "  %-15s %s\n", $$1, $$2}'

# ── Aggregates ─────────────────────────────────────────────────────────
bootstrap-mac: brew-setup brew-install git-setup omz-setup iterm2-setup cursor-setup claude-setup ## Bootstrap the development environment on mac (backs up existing dotfiles)

bootstrap-linux: git-setup omz-setup ## Bootstrap git and zsh on linux (backs up existing dotfiles)

dump: brew-dump cursor-dump ## Run all dumps (brew-dump, cursor-dump)

# ── Homebrew ───────────────────────────────────────────────────────────
brew-setup: link-brew ## Install Homebrew
	@[ -x "$(BREW)" ] || \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew-install: ## Install packages from Brewfile (retries transient failures)
	@for i in 1 2; do \
		$(BUNDLE) && exit 0; \
		echo "brew bundle attempt $$i failed; retrying in 5s..." >&2; \
		sleep 5; \
	done; \
	$(BUNDLE)

brew-dump: ## Overwrite Brewfile from current environment
	$(BUNDLE) dump --force --no-vscode

brew-prune: ## Remove packages not in Brewfile
	$(BUNDLE) cleanup --force --no-vscode

# ── Tools ──────────────────────────────────────────────────────────────
git-setup: link-git ## Configure git

omz-setup: link-zsh ## Install Oh My Zsh and plugins
	@[ -d "$(HOME)/.oh-my-zsh" ] || \
		RUNZSH=no KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] || \
		git clone https://github.com/zsh-users/zsh-autosuggestions "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	@[ -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] || \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

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

claude-setup: link-claude ## Link Claude config and install plugins from settings.json
	@$(SHELLENV); \
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

link-claude: ## Link Claude CLAUDE.md, settings, hooks, agents, commands, and skills
	@$(call backup_and_link,"$(CURDIR)/claude/CLAUDE.md","$(HOME)/.claude/CLAUDE.md")
	@$(call backup_and_link,"$(CURDIR)/claude/settings.json","$(HOME)/.claude/settings.json")
	@$(call backup_and_link,"$(CURDIR)/claude/hooks","$(HOME)/.claude/hooks")
	@$(call backup_and_link,"$(CURDIR)/claude/agents","$(HOME)/.claude/agents")
	@$(call backup_and_link,"$(CURDIR)/claude/commands","$(HOME)/.claude/commands")
	@$(call backup_and_link,"$(CURDIR)/claude/skills","$(HOME)/.claude/skills")

link-cursor: ## Link Cursor settings.json
	@$(call backup_and_link,"$(CURDIR)/cursor/settings.json","$(CURSOR_USER)/settings.json")

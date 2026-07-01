.PHONY: help bootstrap dump brew-setup brew-install brew-dump brew-prune git-setup omz-setup iterm2-setup cursor-setup cursor-dump claude-setup link-git link-zsh link-brew link-claude link-cursor

CURSOR_USER := $(HOME)/Library/Application Support/Cursor/User

BUNDLEFLAGS  := --global
BIN          := /opt/homebrew/bin
BREW         := $(BIN)/brew
BUNDLE       := $(BREW) bundle $(BUNDLEFLAGS)

help:
	@echo "  bootstrap-mac  - Bootstrap the development environmenton mac (backs up existing dotfiles)"
	@echo "  dump           - Run all dumps (brew-dump, cursor-dump)"
	@echo "  brew-setup     - Install Homebrew"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"
	@echo "  brew-prune     - Remove packages not in Brewfile"
	@echo "  git-setup      - Configure git"
	@echo "  omz-setup      - Install Oh My Zsh and plugins"
	@echo "  iterm2-setup   - Configure iTerm2"
	@echo "  cursor-setup   - Link Cursor settings and install extensions"
	@echo "  cursor-dump    - Overwrite Cursor extensions.txt from current environment"
	@echo "  claude-setup   - Install Claude Code, link config, and install enabled plugins"
	@echo "  link-git       - Link git dotfile"
	@echo "  link-zsh       - Link zsh dotfile"
	@echo "  link-brew      - Link Brewfile"
	@echo "  link-claude    - Link Claude CLAUDE.md, settings, agents, commands, and skills"
	@echo "  link-cursor    - Link Cursor settings.json"

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

bootstrap-mac: brew-setup brew-install git-setup omz-setup iterm2-setup cursor-setup claude-setup brew-dump

dump: brew-dump cursor-dump

brew-setup: link-brew
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	grep -q 'brew shellenv' $$HOME/.zprofile || echo 'eval "$$($(BREW) shellenv)"' >> $$HOME/.zprofile

brew-install:
	eval "$$($(BREW) shellenv sh)" && $(BUNDLE)

brew-dump:
	eval "$$($(BREW) shellenv sh)" && $(BUNDLE) dump --force --no-vscode

brew-prune:
	eval "$$($(BREW) shellenv sh)" && $(BUNDLE) cleanup --force --no-vscode

git-setup: link-git

omz-setup: link-zsh
	RUNZSH=no KEEP_ZSHRC=yes \
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true

iterm2-setup:
	/usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(CURDIR)/iterm2"
	/usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	osascript -e 'tell application "iTerm2" to quit'
	killall cfprefsd

cursor-setup: link-cursor
	@eval "$$($(BREW) shellenv sh)"; \
	while read -r ext; do \
		[ -z "$$ext" ] && continue; \
		cursor --install-extension "$$ext"; \
	done < "$(CURDIR)/cursor/extensions.txt"

cursor-dump:
	eval "$$($(BREW) shellenv sh)" && cursor --list-extensions > "$(CURDIR)/cursor/extensions.txt"

link-git:
	@$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$$HOME/.gitconfig")

link-zsh:
	@$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$$HOME/.zshrc")

link-brew:
	@$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$$HOME/.Brewfile")

claude-setup: link-claude
	curl -fsSL https://claude.ai/install.sh | bash
	@python3 -c "import json; print('\n'.join(json.load(open('$(CURDIR)/claude/settings.json')).get('enabledPlugins', {})))" | \
	while read -r plugin; do \
		[ -z "$$plugin" ] && continue; \
		claude plugin install "$$plugin" || true; \
	done

link-claude:
	@$(call backup_and_link,"$(CURDIR)/claude/CLAUDE.md","$$HOME/.claude/CLAUDE.md")
	@$(call backup_and_link,"$(CURDIR)/claude/settings.json","$$HOME/.claude/settings.json")
	@$(call backup_and_link,"$(CURDIR)/claude/agents","$$HOME/.claude/agents")
	@$(call backup_and_link,"$(CURDIR)/claude/commands","$$HOME/.claude/commands")
	@$(call backup_and_link,"$(CURDIR)/claude/skills","$$HOME/.claude/skills")

link-cursor:
	@$(call backup_and_link,"$(CURDIR)/cursor/settings.json","$(CURSOR_USER)/settings.json")

.PHONY: bootstrap brew-setup brew-install brew-dump brew-prune git-setup omz-setup iterm2-setup

BUNDLEFLAGS  := --global --no-vscode
BIN          := /opt/homebrew/bin
BREW         := $(BIN)/brew
BUNDLE       := $(BREW) bundle $(BUNDLEFLAGS)

help:
	@echo "  bootstrap      - Bootstrap the development environment (backs up existing dotfiles)"
	@echo "  brew-setup     - Install Homebrew"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"
	@echo "  brew-prune     - Remove packages not in Brewfile"
	@echo "  git-setup      - SConfigure git"
	@echo "  omz-setup      - Install Oh My Zsh and plugins"
	@echo "  iterm2-setup   - Configure iTerm2"

define backup_and_link
	src="$(1)"; dest="$(2)"; \
	[ -e "$$dest" ] && [ ! -L "$$dest" ] && mv "$$dest" "$$dest.backup" && echo "Backed up existing $$dest to $$dest.backup"; \
	{ [ -e "$$dest" ] || [ -L "$$dest" ]; } && rm -rf "$$dest"; \
	mkdir -p "$$(dirname "$$dest")" && ln -s "$$src" "$$dest" && echo "Linked $$dest to $$src"
endef

bootstrap: brew-setup brew-install git-setup omz-setup iterm2-setup brew-dump

brew-setup:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	grep -q 'brew shellenv' $$HOME/.zprofile || echo 'eval "$$($(BREW) shellenv)"' >> $$HOME/.zprofile
	@$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$$HOME/.Brewfile")

brew-install:
	$(BUNDLE)

brew-dump:
	$(BUNDLE) dump --force

brew-prune:
	$(BUNDLE) cleanup --force

git-setup:
	@$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$$HOME/.gitconfig")

omz-setup:
	@$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$$HOME/.zshrc")
	RUNZSH=no KEEP_ZSHRC=yes \
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true

iterm2-setup:
	/usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(CURDIR)/iterm2"
	/usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	osascript -e 'tell application "iTerm2" to quit'
	killall cfprefsd
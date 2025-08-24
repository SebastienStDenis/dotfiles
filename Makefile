.PHONY: bootstrap brew-setup brew-install omz-setup iterm2-setup link brew-dump brew-prune

BUNDLEFLAGS  := --global
BIN          := /opt/homebrew/bin
BREW         := $(BIN)/brew
BUNDLE       := $(BREW) bundle $(BUNDLEFLAGS)

help:
	@echo "  bootstrap      - Bootstrap the development environment"
	@echo "  brew-setup     - Install Homebrew"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  omz-setup      - Install Oh My Zsh and plugins"
	@echo "  iterm2-setup   - Configure iTerm2"
	@echo "  link           - Symlink dotfiles (backs up existing dotfiles)"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"
	@echo "  brew-prune     - Remove packages not in Brewfile"

define backup_and_link
	src="$(1)"; dest="$(2)"; \
	[ -e "$$dest" ] && [ ! -L "$$dest" ] && mv "$$dest" "$$dest.backup" && echo "Backed up existing $$dest to $$dest.backup"; \
	{ [ -e "$$dest" ] || [ -L "$$dest" ]; } && rm -rf "$$dest"; \
	mkdir -p "$$(dirname "$$dest")" && ln -s "$$src" "$$dest" && echo "Linked $$dest to $$src"
endef

bootstrap: brew-setup brew-install omz-setup iterm2-setup link brew-dump

brew-setup:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	grep -q 'brew shellenv' $$HOME/.zprofile || echo 'eval "$$($(BREW) shellenv)"' >> $$HOME/.zprofile

brew-install:
	$(BUNDLE)

omz-setup:
	RUNZSH=no \
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true

iterm2-setup:
	/usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(CURDIR)/iterm2"
	/usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
	osascript -e 'tell application "iTerm2" to quit'
	killall cfprefsd

link:
	$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$$HOME/.Brewfile")
	$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$$HOME/.gitconfig")
	$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$$HOME/.zshrc")

brew-dump:
	$(BUNDLE) dump --force

brew-prune:
	$(BUNDLE) cleanup --force
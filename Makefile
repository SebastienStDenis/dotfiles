.PHONY: help init bootstrap stow stow-adopt brew-install brew-dump brew-prune

HOMEBREW_BIN = $(shell test -x /opt/homebrew/bin/brew && echo /opt/homebrew/bin || echo /usr/local/bin)

BUNDLEFLAGS  := --global
STOWFLAGS    := -d . -t $(HOME) -v
PACKAGES     := brew git zsh

BREW         := $(HOMEBREW_BIN)/brew
STOW         := $(HOMEBREW_BIN)/stow $(STOWFLAGS) $(PACKAGES)
BUNDLE       := $(BREW) bundle $(BUNDLEFLAGS)

help:
	@echo "  init           - Install Homebrew and other dependencies"
	@echo "  bootstrap	    - Bootstrap the development environment (removes existing dotfiles)"
	@echo "  stow           - Symlink $(PACKAGES)"
	@echo "  stow-adopt     - Symlink and override repo content with existing home dotfiles"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-prune     - Remove packages not in Brewfile"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"

init:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$$($(BREW) shellenv)"' >> ~/.zprofile
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	$(BREW) bundle --file=./brew/.Brewfile

bootstrap: init
	rm -f $(HOME)/.zshrc
	$(STOW)

stow:
	$(STOW)

stow-adopt:
	$(STOW) --adopt

brew-install:
	$(BUNDLE)

brew-dump:
	$(BUNDLE) dump --force

brew-prune:
	$(BUNDLE) cleanup --force
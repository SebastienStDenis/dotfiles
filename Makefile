.PHONY: help stow stow-adopt stow-override brew-install brew-prune brew-apply brew-dump

BREWFLAGS 	:= --global
BUNDLE    	:= brew bundle $(BREWFLAGS)
STOWFLAGS  	:= -d . -t $(HOME) -v
STOW	  	:= stow $(STOWFLAGS)
PACKAGES 	:= brew git zsh

# Default target
help:
	@echo "  stow           - Symlink $(PACKAGES)"
	@echo "  stow-adopt     - Symlink and adopt existing home dotfiles"
	@echo "  stow-override  - Symlink and override existing home dotfiles with repo content"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-prune     - Remove packages not in Brewfile"
	@echo "  brew-apply     - Make environment match Brewfile (install + prune)"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"

stow:
	@$(STOW) $(PACKAGES)

stow-adopt:
	@$(STOW) --adopt $(PACKAGES)

stow-override:
	@$(STOW) --override $(PACKAGES)

brew-install:
	@$(BUNDLE)

brew-prune:
	@$(BUNDLE) cleanup --force

brew-apply: brew-install brew-prune

brew-dump:
	@$(BUNDLE) dump --force
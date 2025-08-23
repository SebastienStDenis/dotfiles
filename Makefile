.PHONY: help stow stow-adopt stow-override brew-install brew-prune brew-apply brew-dump

BREWFLAGS := --global
BUNDLE    := brew bundle $(BREWFLAGS)

# Default target
help:
	@echo "Available commands:"
	@echo "  stow           - Symlink brew, git, and zsh"
	@echo "  stow-adopt     - Symlink and adopt existing home dotfiles"
	@echo "  stow-override  - Symlink and override existing home dotfiles with repo content"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-prune     - Remove packages not in Brewfile"
	@echo "  brew-apply     - Make environment match Brewfile (install + prune)"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"

stow:
	@echo "Applying symlinks for brew, git, and zsh..."
	stow -d . -t $(HOME) -v brew git zsh

stow-adopt:
	@echo "Force applying symlinks (stow will adopt existing files)..."
	stow -d . -t $(HOME) -v --adopt brew git zsh

stow-override:
	@echo "Overriding existing home dotfiles with repo content..."
	stow -d . -t $(HOME) -v --override brew git zsh

brew-install:
	$(BUNDLE)

brew-prune:
	$(BUNDLE) cleanup --force

brew-apply: brew-install brew-prune

brew-dump:
	$(BUNDLE) dump --force
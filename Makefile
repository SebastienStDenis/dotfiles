.PHONY: brew-setup omz-setup link brew-install brew-dump brew-prune bootstrap

BUNDLEFLAGS  := --global
BIN          := /opt/homebrew/bin
BREW         := $(BIN)/brew
BUNDLE       := $(BREW) bundle $(BUNDLEFLAGS)

help:
	@echo "  bootstrap      - Bootstrap the development environment"
	@echo "  brew-setup     - Install Homebrew"
	@echo "  omz-setup      - Install Oh My Zsh and plugins"
	@echo "  link           - Symlink dotfiles (backs up existing dotfiles)"
	@echo "  brew-install   - Install packages from Brewfile"
	@echo "  brew-dump      - Overwrite Brewfile from current environment"
	@echo "  brew-prune     - Remove packages not in Brewfile"

define backup_and_link
	src="$(1)"; dest="$(2)"; \
	[ -e "$$dest" ] && [ ! -L "$$dest" ] && mv "$$dest" "$$dest.backup" && echo "Backed up existing $$dest to $$dest.backup"; \
	{ [ -e "$$dest" ] || [ -L "$$dest" ]; } && rm -rf "$$dest"; \
	mkdir -p "$$(dirname "$$dest")" && ln -s "$$src" "$$dest" && echo "Linked $$dest to $$src"
endef

brew-setup:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	grep -q 'brew shellenv' $$HOME/.zprofile || echo 'eval "$$($(BREW) shellenv)"' >> $$HOME/.zprofile

omz-setup:
	RUNZSH=no \
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
	git clone https://github.com/zsh-users/zsh-syntax-highlighting $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true

link:
	@$(call backup_and_link,"$(CURDIR)/brew/.Brewfile","$$HOME/.Brewfile")
	@$(call backup_and_link,"$(CURDIR)/git/.gitconfig","$$HOME/.gitconfig")
	@$(call backup_and_link,"$(CURDIR)/zsh/.zshrc","$$HOME/.zshrc")

brew-install:
	$(BUNDLE)

brew-dump:
	$(BUNDLE) dump --force

brew-prune:
	$(BUNDLE) cleanup --force

bootstrap: brew-setup omz-setup link brew-install brew-dump
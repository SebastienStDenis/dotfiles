eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

alias g='git'
alias dc='docker'
alias ca='claude agents'

# Open Cursor at the current folder's git root (falls back to cwd)
c() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || root=$PWD
  cursor "$root"
}

export DISABLE_UNTRACKED_FILES_DIRTY=true
export EDITOR='nvim'

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="kolo"

HISTSIZE=100000
SAVEHIST=100000
setopt HIST_REDUCE_BLANKS
unsetopt SHARE_HISTORY

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

export FZF_DEFAULT_OPTS="--height=40%"

plugins=(
  git
  z
  fzf
  docker
  kubectl
  helm
  kind
)

source "$ZSH/oh-my-zsh.sh"

source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

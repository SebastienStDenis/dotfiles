[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.opencode/bin" ]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi

alias g='git'
alias d='docker'
alias dc='docker compose'
alias ca='claude agents'
alias brup='brew update && brew upgrade && brew cleanup'

export DISABLE_UNTRACKED_FILES_DIRTY=true
export EDITOR='nvim'

if command -v gh >/dev/null 2>&1; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
fi

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
  z
  fzf
  docker
  kubectl
  helm
  kind
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

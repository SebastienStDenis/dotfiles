alias g='git'
alias dc='docker'

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
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
)

source "$ZSH/oh-my-zsh.sh"

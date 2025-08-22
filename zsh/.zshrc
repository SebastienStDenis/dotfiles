alias g='git'
export DISABLE_UNTRACKED_FILES_DIRTY=true
export EDITOR='nvim'

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="kolo"

HISTSIZE=100000
SAVEHIST=100000

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

plugins=(
  git
  z
  zsh-autosuggestions
  fzf
  zsh-syntax-highlighting
)

export FZF_DEFAULT_OPTS='--height=40%'

source "$ZSH/oh-my-zsh.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

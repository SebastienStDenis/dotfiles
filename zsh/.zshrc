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
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Source key bindings + completion from Homebrew prefix
if command -v brew >/dev/null; then
  FZF_BASE="$(brew --prefix)/opt/fzf"
  [ -f "$FZF_BASE/shell/key-bindings.zsh" ] && source "$FZF_BASE/shell/key-bindings.zsh"
  [ -f "$FZF_BASE/shell/completion.zsh" ]    && source "$FZF_BASE/shell/completion.zsh"
fi

export FZF_DEFAULT_OPTS="--height=40%"
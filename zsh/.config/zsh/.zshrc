export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  archlinux
  ssh-agent
)

source $ZSH/oh-my-zsh.sh

# History configuration
SAVEHIST=100000
HISTSIZE=100000
HISTFILE="${ZDOTDIR}/.zsh_history"
setopt appendhistory
export HISTFILE SAVEHIST ZSH_AUTOSUGGEST_STRATEGY

# Zsh configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Custom functions
zshrc() {
  $EDITOR "${ZDOTDIR}/.zshrc"
}

# Application configuration
export LIBVIRT_DEFAULT_URI=qemu:///system # QEMU networking

# Path extensions and exports
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export PATH="$HOME/.local/bin:$CARGO_HOME/bin:$BUN_INSTALL/bin:$PATH"

# Shell extensions
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Aliases
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
    export STARSHIP_CACHE=$XDG_CACHE_HOME/starship
    export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
fi

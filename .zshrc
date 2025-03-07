# Configuración básica de ZSH
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Historia
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Autocompletado
autoload -Uz compinit && compinit

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"

# Aliases personalizados
alias ll='ls -la'
alias vimdiff='nvim -d'

# Configuración para Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Añadir directorios de Nix al PATH
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Habilitar experimentales para Flakes
export NIX_CONFIG="experimental-features = nix-command flakes"

# Configuración para Neovim
export EDITOR="nvim"
export VISUAL="nvim"

# Alias para Neovim
alias vim="nvim"
alias vi="nvim"
alias v="nvim"


# Focused integrations, loaded only when their commands exist.
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
(( $+commands[fzf] )) && source <(fzf --zsh)

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

if (( $+commands[lunafetch] )) && [[ -o interactive && -o login && -z "$SSH_CONNECTION" && -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]]; then
  lunafetch
fi

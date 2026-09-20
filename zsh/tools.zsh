# Focused integrations, loaded only when their commands exist.
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
(( $+commands[fzf] )) && source <(fzf --zsh)

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

if (( $+commands[lunafetch] )) && [[ -o interactive && $SHLVL -eq 1 && -z "$SSH_CONNECTION" && -z "$TMUX" && "$TERM_PROGRAM" != "vscode" && -z "$NEPTUNE_FETCH_SHOWN" ]]; then
  export NEPTUNE_FETCH_SHOWN=1
  lunafetch
fi

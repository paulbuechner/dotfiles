[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/conda.zsh ]] && source ~/.zsh/conda.zsh

# Load oh-my-posh
command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init zsh --config "$HOME/.mytheme.omp.json")"

# Load jenv
command -v jenv >/dev/null && eval "$(jenv init -)"

true

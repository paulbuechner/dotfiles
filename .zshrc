[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/conda.zsh ]] && source ~/.zsh/conda.zsh

# Load oh-my-posh
eval "$(oh-my-posh init zsh --config "/Users/Paul/.mytheme.omp.json")"

# Load jenv
eval "$(jenv init -)"

alias k="kubectl"
alias kc="kubectx"
alias kn="kubens"
alias tf="terraform"
alias a="ansible"
alias ap="ansible-playbook"
if command -v eza >/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza --icons --group-directories-first -l"
fi
alias prx="proxmox-manager"

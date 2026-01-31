
###############################################################################
###############################################################################

export PS1="θ "
set -o vi
export EDITOR=nvim
alias vim="nvim"
alias t="tree -L 1 -C -I '*pyc|*nbc|*nbi|__init__.py|__pycache__'"
export PATH="~/.config/nvim/plugged/fzf/bin:$PATH"

# Git + Bash completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
if [ ! -f ~/.git-completion.bash ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
fi
source ~/.git-completion.bash
export PATH="~/.local/bin:$PATH"
conda config --set changeps1 False
export PYTHONBREAKPOINT=ipdb.set_trace

###############################################################################
###############################################################################

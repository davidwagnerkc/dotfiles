{
  description = "dev";
  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        ripgrep 
        tmux 
        nodejs 
        fd
        tree
        fzf
        neovim 
        bashInteractive 
        bash-completion
        gcc
        uv
      ];
      shell = "${pkgs.bashInteractive}/bin/bash";
      shellHook = ''
        export SHELL=${pkgs.bashInteractive}/bin/bash
        module purge
        cd "$HOME/git/dotfiles/"
        uv sync
        source "$HOME/git/dotfiles/.venv/bin/activate"
        export GIT_SSH_COMMAND='ssh -F ~/.ssh/config'
        if [[ $- == *i* ]] && [ -f "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh" ]; then
          source "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
        fi
        if set -o | grep -q '^vi[[:space:]]*off'; then
          set -o vi
        fi
        export FZF_DEFAULT_COMMAND="fd --type f"
        export PATH="~/.config/nvim/plugged/fzf/bin:$PATH"
        if [ ! -f ~/.git-completion.bash ]; then
          curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
        fi
        source ~/.git-completion.bash
        export PYTHONBREAKPOINT=ipdb.set_trace
        if ! tmux has-session -t jl 2>/dev/null; then
            export JL_OOD_HOST=ood.umkc.edu
            export JL_HOST=$(hostname -f)
            export JL_PORT=$(shuf -i 10000-30000 -n1)
            export JL_TOKEN=$(openssl rand -hex 16)
            export JL_URL="https://$JL_OOD_HOST/node/$JL_HOST/$JL_PORT/lab?token=$JL_TOKEN"
            tmux new -d -s jl
            tmux send-keys -t jl "jupyter lab \
              --no-browser \
              --ip=0.0.0.0 \
              --port=$JL_PORT \
              --NotebookApp.token=$JL_TOKEN \
              --ServerApp.base_url=/node/$JL_HOST/$JL_PORT/ \
              --ServerApp.allow_origin=https://$JL_OOD_HOST \
              --ServerApp.allow_credentials=True \
              --ServerApp.allow_remote_access=True" C-m
            echo -e "host: $JL_HOST\nport: $JL_PORT\ntoken: $JL_TOKEN" > connection.yml
            echo $JL_URL
        fi
        if ! tmux has-session -t dev 2>/dev/null; then
          tmux new -s dev
        else
          tmux a -t dev
        fi
      '';
    };
  };
}

/*
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/ohpc/pub/apps/anaconda/2024.10/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/ohpc/pub/apps/anaconda/2024.10/etc/profile.d/conda.sh" ]; then
        . "/opt/ohpc/pub/apps/anaconda/2024.10/etc/profile.d/conda.sh"
    else
        export PATH="/opt/ohpc/pub/apps/anaconda/2024.10/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
conda activate zdev
*/

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

        set -o vi
        export EDITOR=nvim
        alias vim="nvim"
        alias t="tree -L 1 -C -I '*pyc|*nbc|*nbi|__init__.py|__pycache__'"
        export PATH="~/.config/nvim/plugged/fzf/bin:$PATH"
        if [ ! -f ~/.git-completion.bash ]; then
          curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
        fi
        source ~/.git-completion.bash
        export PYTHONBREAKPOINT=ipdb.set_trace
      '';
    };
  };
}

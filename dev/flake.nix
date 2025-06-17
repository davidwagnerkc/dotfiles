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
      buildInputs = [
        pkgs.ripgrep 
        pkgs.tmux 
        pkgs.nodejs 
        pkgs.fd
        pkgs.tree
        pkgs.fzf
        pkgs.neovim 
        pkgs.bashInteractive 
        pkgs.bash-completion
      ];
      shellHook = ''
        if [[ $- == *i* ]] && [ -f "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh" ]; then
          source "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
        fi
        if set -o | grep -q '^vi[[:space:]]*off'; then
          set -o vi
        fi
        export FZF_DEFAULT_COMMAND="fd --type f"
      '';
    };
  };
}

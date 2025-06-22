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
        gcc
        uv
      ];
      shell = "${pkgs.bashInteractive}/bin/bash";
      shellHook = ''
        export SHELL=${pkgs.bashInteractive}/bin/bash
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

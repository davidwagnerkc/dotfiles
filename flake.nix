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
        glibcLocales
      ];
      shell = "${pkgs.bashInteractive}/bin/bash";
      shellHook = ''
        export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export SHELL=${pkgs.bashInteractive}/bin/bash
        [ -f ~/.bashrc ] && source ~/.bashrc
        if ! tmux has-session -t dev 2>/dev/null; then
          tmux new -s dev
        else
          tmux a -t dev
        fi
      '';
    };
  };
}

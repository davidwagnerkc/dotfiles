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
        awscli2
        nload
        s5cmd
      ];
      shell = "${pkgs.bashInteractive}/bin/bash";
      shellHook = ''
        export SHELL=${pkgs.bashInteractive}/bin/bash
        export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
        export LANG=en_US.utf8
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

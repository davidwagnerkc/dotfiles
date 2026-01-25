{
  description = "dev";
  nixConfig = {
    extra-substituters = [ "https://claude-code.cachix.org" ];
    extra-trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };
  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    claude-code.url  = "github:sadjow/claude-code-nix";
  };
  outputs = { self, nixpkgs, claude-code, ... }: let
    system = "x86_64-linux";
    pkgs   = import nixpkgs {
      inherit system;
      overlays = [ claude-code.overlays.default ];
      config.allowUnfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "claude-code-bun"
        ];
    };
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
        google-cloud-sdk
        (claude-code-bun.override { bunBinName = "claude"; })
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

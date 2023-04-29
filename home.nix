{ config, pkgs, lib, ... }:

{
  home.stateVersion = "22.11";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.neovim.enable = true;
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  programs.vscode.enable = true;
  programs.git.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.nushell.enable = true;
  programs.readline.enable = true;

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    bat

    jq
    nodePackages.typescript
    nodejs
    yarn
    jdk17
    terraform
    tfsec
    clojure
    leiningen
    clj-kondo
    babashka
    just
    awscli2

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it

  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ];
}
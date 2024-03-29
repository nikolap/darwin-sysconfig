{ pkgs, lib, ... }:

let
  isPersonal = true;
  isDI = false;
  localName = "nik-macbook";

in {
  # Nix configuration ------------------------------------------------------------------------------

  nix.settings.substituters = [ "https://cache.nixos.org/" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];
  nix.settings.trusted-users = [ "@admin" ];
  nix.configureBuildUsers = true;

  #  sysctl -n hw.ncpu
  nix.settings = {
    max-jobs = 10;
    cores = 10;
  };

  environment.variables = {
    EDITOR = lib.mkForce "nvim";
    FZFZ_RECENT_DIRS_TOOL = "fasd";
  };

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
    # plugins = [
    #         {
    #           # will source zsh-autosuggestions.plugin.zsh
    #           name = "zsh-autosuggestions";
    #           src = pkgs.fetchFromGitHub {
    #             owner = "zsh-users";
    #             repo = "zsh-autosuggestions";
    #             rev = "v0.7.0";
    #             sha256 = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
    #           };
    #         }
    #       ];
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"
      export GPG_TTY=$(tty)
      export PATH=$PATH:~/.docker/bin
    '';
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  environment.systemPackages = with pkgs; [
    tailscale
    cachix
    fzf
    coreutils-prefixed
    cmake
    zoxide
    starship
    jsbeautifier
    shfmt
    shellcheck
    rust-analyzer
    rustup
    silver-searcher
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    imagemagick
    zstd
    fasd
    tree
    fira-code
    cloc
    editorconfig-core-c
    sqlite
    texlive.combined.scheme-medium
    fd
    gnugrep
    binutils
    neovim
    nix-output-monitor
    nixpkgs-fmt
    oath-toolkit
    dnsmasq
    git-filter-repo
    git-lfs
    moreutils
    (pkgs.writeScriptBin "rebuild" ''
      cd ~/.config/sysconfig && \
      ${pkgs.nix-output-monitor}/bin/nom build .#darwinConfigurations.${localName}.system && \
      ./result/sw/bin/darwin-rebuild switch --flake .
    '')
    (pkgs.writeScriptBin "local-dnsmasq" ''
      sudo ${pkgs.dnsmasq}/bin/dnsmasq --listen-address=127.0.0.1 --port=53 --address=/local/127.0.0.1
    '')
  ];

  environment.shellAliases = { vim = "nvim"; };

  environment.postBuild = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';
  nix.nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];

  programs.vim.enable = true;
  programs.nix-index.enable = true;

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    recursive
    fira-code
    emacs-all-the-icons-fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Keyboard
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [{
      HIDKeyboardModifierMappingSrc = 30064771129;
      HIDKeyboardModifierMappingDst = 30064771148;
    }];
  };

  system.activationScripts.postUserActivation.text = ''
    sudo sh -c 'echo "nameserver 127.0.0.1" >> /etc/resolver/local'
  '';

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    casks = [
      "raycast"
      "orbstack"
      "iterm2"
      "spectacle"
      "jetbrains-toolbox"
      "spotify"
      "slack"
      "google-chrome"
      "insomnia"
      "zoom"
      "webex"
      "postman"
    ] ++ lib.optionals isPersonal [
      "audacity"
      "firefox"
      "vlc"
      "browserosaurus"
      "protonvpn"
      "steam"
      "whatsapp"
      "discord"
      "telegram"
      "grandperspective"
      "guitar-pro"
      "jellyfin-media-player"
      "netnewswire"
      "signal"
      "ticktick"
      "transmission"
      "tresorit"
      "authy"
      "bitwarden"
    ] ++ lib.optionals isDI [ "1password" "tunnelblick" "mongodb-compass" ];
  };
}

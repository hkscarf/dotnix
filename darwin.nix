{ pkgs, lib, config, ... }:
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixVersions.nix_2_19; # Per https://discourse.nixos.org/t/how-to-upgrade-nix-on-macos-with-home-manager/25147/4

  # Necessary for using flakes on this system.
  nix.settings = {
    # Generated by https://github.com/DeterminateSystems/nix-installer, version 0.6.0.
    "bash-prompt-prefix" = "(nix:$name)\040";
    "build-users-group" = "nixbld";
    "extra-nix-path" = "nixpkgs=flake:nixpkgs";
    "experimental-features" = "nix-command flakes repl-flake";
    "auto-optimise-store" = true;
    "max-jobs" = "auto";
    "upgrade-nix-store-path-url" = "https://install.determinate.systems/nix-upgrade/stable/universal";


    # Manual Additions
    "extra-trusted-substituters" = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    "extra-trusted-public-keys" = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];

  # Create /etc/zshrc | /etc/bashrc that loads the nix-darwin environment.
  # FIXME `nix-darwin` can't set default shell
  programs.bash.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";

  users.users.hkscarf = {
    name = "hkscarf";
    home = "/Users/hkscarf";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    config.nix.package # Per https://discourse.nixos.org/t/how-to-upgrade-nix-on-macos-with-home-manager/25147/4

    # Programming Languages and Environments
    python313
    # haskell.compiler.ghc94 # ghc-9.4.5 (lts-21.3)
    nodejs_21
    nodePackages.pnpm

    # Infra

    # Data Store
    sqlite

    # Shell
    bashInteractive

    # CLI Programs
    bat # modern `cat`
    delta # for diff-ing
    procs # modern `ps`
    tldr # quick usage guide when you don't need the full manpages
    tree # visualize directory tree
    visidata # Excel for CLI

    # Nix-specific Tools
    cachix
    haskellPackages.nix-derivation
    nil # https://github.com/oxalica/nil#readme
    nix-direnv
    nix-info
    nix-tree
    nixpkgs-fmt
    sbomnix
    vulnix

    # GUI Apps

    # Other

    # Mac OS Setup - Scarf Deps - https://www.notion.so/scarf/Mac-OS-setup-...
    # darwin.libiconv
    # libpqxx # - FIXME using homebrew for now
    # pcre - FIXME using homebrew for now
    # rdkafka - FIXME using homebrew for now
    # rocksdb
    # openssl_3_1
    # tmux
    curlWithGnuTls
    wget
  ];

  ##### Mac-Specific Options ###################################################

  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCommandAndLeftAlt = true;
  };

  ##### Nix-Darwin Packages + Services + Options ###################################################

  homebrew = {
    enable = true; # NOTE: Doesn't install homebrew. See https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable
    brews = [
      {
        name = "libiconv";
      }
      {
        name = "libpq";
      }
      {
        name = "librdkafka";
      }
      {
        name = "openssl";
      }
      {
        name = "pcre";
      }
      {
        name = "postgresql@11";
      }
      {
        name = "rocksdb";
      }
      {
        name = "tmux";
      }
    ];
    casks = [
      # https://stackoverflow.com/a/44719239 https://stackoverflow.com/a/49719638
      "docker" # https://formulae.brew.sh/cask/docker
    ];
  };

  ## Postgres Setup

  # # From https://github.com/LnL7/nix-darwin/issues/339#issuecomment-1765304524
  # system.activationScripts.preActivation = {
  #   enable = true;
  #   text = ''
  #     if [ ! -d "/var/lib/postgresql/" ]; then
  #       echo "creating PostgreSQL data directory..."
  #       sudo mkdir -m 750 -p /var/lib/postgresql/
  #       chown -R hkscarf:staff /var/lib/postgresql/
  #     fi
  #   '';
  # };

  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_12;
  #   initdbArgs = [
  #     "-U hkscarf"
  #     "--pgdata=/var/lib/postgresql/12"
  #     "--encoding=UTF8"
  #     "--auth=trust"
  #     # "--no-locale"
  #   ];
  # };

  # launchd.user.agents.postgresql.serviceConfig = {
  #   StandardErrorPath = "/tmp/postgres.error.log";
  #   StandardOutPath = "/tmp/postgres.log";
  # };
}

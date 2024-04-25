{ pkgs, lib, config, ... }:
{
  imports = [
    # Make vscode settings writable. Mutable VSCode Settings module per: 
    #  - https://github.com/nix-community/home-manager/issues/1800#issuecomment-1924321850
    #  - https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa

   # (import (builtins.fetchurl {
   #   url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/mutability.nix";
   #   sha256 = "4b5ca670c1ac865927e98ac5bf5c131eca46cc20abf0bd0612db955bfc979de8";
   # }) { inherit config lib; })

   # (import (builtins.fetchurl {
   #   url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
   #   sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
   # }) { inherit config lib pkgs; })
  ];
  
  ##################################################################################################
  ### Configuring Nix + Home-Manager
  ##################################################################################################

  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  ##################################################################################################
  ### Env Vars
  ##################################################################################################

  home.sessionVariables = {
    EDITOR = "code";
  };

  ##################################################################################################
  ### Configurable Home-Manager Services + Packages (alphabetical)
  ##################################################################################################

  ## See available configuration options at either:
  ## * Search - https://home-manager-options.extranix.com
  ## * Manual - https://nix-community.github.io/home-manager/options.xhtml


  ## TODO Enable and check
  programs.awscli.enable = true;
  programs.awscli = {
    # Configuration written to $HOME/.aws/credentials.
  #   credentials = {
  #     "default" = {
  #       "credential_process" = "${pkgs.pass}/bin/pass show aws";  # FIXME TODO Bitwarden??
  # https://github.com/grdryn/nix-home-manager-config/blob/59e9d1b31a7b04334dbe783bdb2759cd465c3c56/scripts/aws-bitwarden/aws-bitwarden.sh
  # https://github.com/grdryn/nix-home-manager-config/blob/59e9d1b31a7b04334dbe783bdb2759cd465c3c56/shell.nix#L177C1-L178C1
  # "credential_process" = "${pkgs.bitwarden-cli}/bin/bw get username 'AWS Access Key'";  # FIXME TODO Bitwarden??
  # https://github.com/greg-hellings/nixos-config/blob/a61b23c5f45399482f062ccee3350937b8205378/overlays/configure_aws_creds.nix#L4
  #     };
  #   };
    # Configuration written to $HOME/.aws/config.
    settings = {
      "default" = {
        region = "us-west-2";
        output = "json";
      };
    };
  };

  programs.bash.enable = true;
  programs.bash = {
    profileExtra = builtins.readFile ./bash_profile;
    initExtra = builtins.readFile ./bashrc;

    ## Per https://github.com/nix-community/home-manager/issues/3133#issuecomment-1320315536
    # turn off the automated completion injection
    enableCompletion = false;

    # 1. Manually import completions using `-z` to check if it's been loaded instead of `-v`
    # 2. Add nix binaries to PATH (for some reason not getting set elsewhere?)
    bashrcExtra = ''
      if [[ -z BASH_COMPLETION_VERSINFO ]]; then
        . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
      fi

      # export PATH="/run/current-system/sw/bin:$PATH"
      # export PATH="/etc/profiles/per-user/hkscarf/bin:$PATH"

      export PATH="/opt/homebrew/bin:$PATH"
      export PATH="/opt/homebrew/bin/opt/postgresql@14/bin:$PATH"
      export LDFLAGS="-L/usr/local/opt/postgresql@14/lib"
      export CPPFLAGS="-I/usr/local/opt/postgresql@14/include"

      export PATH="$HOME/.ghcup/bin:$PATH"
    '';

    ## Per https://github.com/nix-community/home-manager/blob/bb4b25b302dbf0f527f190461b080b5262871756/modules/programs/bash.nix#L86
    # Modify default option set to remove macOS-incompatible options
    shellOptions = [

      # Append to history file rather than replacing it.
      "histappend"

      # check the window size after each command and, if
      # necessary, update the values of LINES and COLUMNS.
      "checkwinsize"

      # Extended globbing.
      "extglob"
      # "globstar"  # unavailable on macOS

      # Warn if closing shell with running jobs.
      # "checkjobs"  # unavailable on macOS
    ];
  };

  programs.direnv.enable = true;
  programs.direnv = {
    nix-direnv.enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.eza.enable = true;
  programs.eza = {
    git = true;
    # enableBashIntegration = true;
    # enableNushellIntegration = true;
  };

  programs.fzf.enable = true;
  programs.fzf = {
    enableBashIntegration = true;
  };

  # Gitconfig written to ~/.config/git/config
  programs.git.enable = true;
  programs.git = {
    includes = [{ path = "~/.config/nixpkgs/gitconfig"; }];
    # ignores = [
    #   *.local
    # ];
    userEmail = "heneli.kailahi@scarf.sh";
    userName = "Heneli";
  };

  programs.jq.enable = true;

  # Settings adapted from https://github.com/the-argus/nixsys/blob/74ee1dd0ac503e241581ee8c3d7b719fa4305e1e/user/primary/lf.nix#L46
  programs.lf.enable = true;
  programs.lf = {
    settings = {
      drawbox = true;
      dirfirst = true;
      icons = true;
      ignorecase = true;
      preview = true;
    };
  };

  programs.neovim.enable = true;
  programs.neovim = {
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [ ];
    extraPython3Packages = ps: [ ];
    plugins = [ ];
  };

  programs.nix-index.enable = true;
  programs.nix-index = {
    enableBashIntegration = true;
  };

  # Pretty dataframe manipulation of shell commands with polars
  programs.nushell.enable = true;
  programs.nushell = {
    extraConfig = ''
      $env.config = {
        show_banner: false,
      }
    '';
  };

  programs.pylint.enable = true;
  programs.pylint = {
    settings = { };
  };

  programs.vscode.enable = true;
  programs.vscode = {
    enableUpdateCheck = false;

    userSettings = {
      "editor" = {
        "fontSize" = 18;
        "formatOnPaste" = true;
        "tabSize" = 2;
        "rulers" = [ 100 ];
      };
      "files.trimTrailingWhitespace" = false;
      "markdown.preview.doubleClickToSwitchToEditor" = false;
      "markdown.preview.openMarkdownLinks" = "inEditor";
      "[markdown]" = {
        "editor.unicodeHighlight.allowedCharacters" = {
          "’" = true;
        };
        "editor.wordWrap" = "on";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "nix.enableLanguageServer" = true; # Enable LSP.
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [ "nixpkgs-fmt" ];
          };
        };
      };
      "window.titleBarStyle" = "native";
    };

    extensions = with pkgs.vscode-extensions; [
      # Nix
      bbenoist.nix
      jnoortheen.nix-ide
      # mkhl.direnv

      # Haskell
      haskell.haskell

      # JS + TS
      esbenp.prettier-vscode

      # Documentation
      unifiedjs.vscode-mdx
      yzhang.markdown-all-in-one

      # Configuration
      tamasfe.even-better-toml

      # Themes
      
      # Version Control
      eamodio.gitlens
      github.vscode-github-actions
      github.vscode-pull-request-github
      
      
      # General
    ]

    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        # Automatically load environments with direnv
        name = "direnv";
        publisher = "mkhl";
        version = "0.17.0";
        sha256 = "sha256-T+bt6ku+zkqzP1gXNLcpjtFAevDRiSKnZaE7sM4pUOs=";
      }
      {
        # A full-featured WYSIWYG editor for markdown
        name = "markdown-editor"; # configure in vscode's settings.json through nix
        publisher = "zaaack";
        version = "0.1.10";
        sha256 = "sha256-K1nczR059BsiHpT1xdtJjpFLl5krt4H9+CrEsIycq9U=";
      }
      {
        # Pretty Typescript Errors
        name = "pretty-ts-errors";
        publisher = "yoavbls";
        version = "0.5.4";
        sha256 = "sha256-SMEqbpKYNck23zgULsdnsw4PS20XMPUpJ5kYh1fpd14=";
      }
      {
        # Documentation with Zeal (linux kapeli/Dash.app alternetive)
        name = "vscode-dash"; # configure in vscode's settings.json through nix
        publisher = "deerawan";
        version = "2.4.0";
        sha256 = "sha256-Yqn59ppNWQRMWGYVLLWofogds+4t/WRRtSSfomPWQy4=";
      }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.zsh.enable = false;
}

{
  pkgs,
  lib,
  ...
}:
{
  home.username = "oliver";

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # TODO: these program configs should be broken up into separate files

  programs.eza.enable = true;
  programs.zoxide.enable = true;

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = {
        body = "";
      };
    };
  };

  programs.ghostty = {
    enable = true;

    # ghostty is installed and managed by homebrew on macos, so we need
    # to give home-manager a fake ghostty package to keep it happy
    package =
      if pkgs.stdenv.isDarwin then
        lib.addMetaAttrs { mainProgram = "ghostty"; } pkgs.emptyDirectory
      else
        pkgs.ghostty;

    settings = {
      theme = "catppuccin-macchiato";
      font-family = "Berkeley Mono";
      mouse-hide-while-typing = true;

      # gui
      title = " ";
      window-title-font-family = "Berkeley Mono";
      window-theme = "dark";
      window-padding-x = 5;
      window-save-state = "always";

      # macos
      macos-titlebar-style = "hidden";
      macos-titlebar-proxy-icon = "hidden";
      macos-option-as-alt = true;
    };
  };

  programs.atuin = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      ui.editor = "nvim";

      user = {
        name = "oliver";
        email = "oliver@wooding.dev";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "oliver";
    userEmail = "oliver@wooding.dev";

    delta.enable = true; # use delta as the git-diff pager
    extraConfig.init.defaultBranch = "main"; # set the default branch name to main
  };

  programs.direnv = {
    enable = true;

    # fish integration is enabled by default because it's set as the login shell
    enableBashIntegration = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "λ";
      character.error_symbol = "λ";

      hostname.ssh_only = false;
      username = {
        show_always = true;
        format = "[$user]($style)@";
      };

      direnv = {
        disabled = false;
        symbol = "direnv";
        format = "[\\($symbol\\)]($style) ";
      };

      format = lib.concatStrings [
        "$direnv"
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$sudo"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];
    };
  };

  programs.hyfetch = {
    enable = true;

    settings = {
      preset = "bisexual";
      mode = "rgb";
      light_dark = "dark";
      lightness = 0.7;
      color_align = {
        mode = "horizontal";
        custom_colors = [ ];
        fore_back = null;
      };
      backend = "neofetch";
      args = null;
      distro = null;
      pride_month_shown = [ ];
      pride_month_disable = false;
    };
  };

  programs.neovide = {
    enable = true;
    settings = {
      frame = "transparent";
      font = {
        normal = "BerkeleyMono Nerd Font";
        size = 15.0;
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}

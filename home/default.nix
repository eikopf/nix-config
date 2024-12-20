{
  config,
  pkgs,
  lib,
  extraPkgs,
  ...
}: {
  home.username = "oliver";
  home.packages 
    = (import ../modules/packages.nix pkgs)
    ++ (extraPkgs pkgs);

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  programs.eza.enable    = true;
  programs.zoxide.enable = true;

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = {
        body = "";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "oliver";
    userEmail = "oliverwooding@icloud.com";

    delta.enable = true; # use delta as the git-diff pager
    extraConfig.init.defaultBranch = "main"; # set the default branch name to main
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
      #character.success_symbol = "";
      #character.error_symbol   = "";

      hostname.ssh_only = false;
      username = {
        show_always = true;
	format = "[$user]($style)@";
      };

      format = lib.concatStrings [
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

  programs.neovide = {
    enable = true;
    settings = { };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}

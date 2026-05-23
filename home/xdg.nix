{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  xdg = {
    enable = true;
    userDirs = {
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
      # xdg-user-dirs 0.20 (April 2026) officially standardised XDG_PROJECTS_DIR,
      # and home-manager master already exposes it as xdg.userDirs.projects. Once
      # this flake is upgraded to release-26.05, move this to userDirs.projects.
      extraConfig = {
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/projects";
      };
    };
  };
}

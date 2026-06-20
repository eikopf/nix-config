{ lib, config, ... }:
{
  programs.firefox = {
    enable = lib.mkDefault false;

    policies = {
      # disable telemetry and annoying features
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLoginsDefault = false;
      SkipTermsOfUser = true;

      # fix download directory to match $XDG_DOWNLOAD_DIR
      DefaultDownloadDirectory = config.xdg.userDirs.download;

      # configure home page
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        Stories = false;
        SponsoredPocket = false;
        SponsoredStories = false;
        Snippets = false;
        Locked = false;
      };

      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhil.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
      };
    };

    profiles.default = {
      isDefault = true;

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}

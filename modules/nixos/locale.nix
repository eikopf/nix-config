{ ... }:
{
  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  # see locale(5) and locale(7) for precise definitions
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_TELEPHONE = "de_CH.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };
}

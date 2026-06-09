{ ... }:
{
  programs.atuin = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;

    flags = [ "--disable-up-arrow" ];
  };
}

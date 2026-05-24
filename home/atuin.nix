{ ... }:
{
  programs.atuin = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    flags = [ "--disable-up-arrow" ];
  };
}

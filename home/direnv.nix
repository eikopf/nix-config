{ ... }:
{
  programs.direnv = {
    enable = true;

    # fish integration is enabled by default because it's set as the login shell
    enableBashIntegration = true;
  };
}

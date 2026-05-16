{ ... }:
{
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
}

{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "oliver";
        email = "oliver@wooding.dev";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}

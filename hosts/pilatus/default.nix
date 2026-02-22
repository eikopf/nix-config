{
  self,
  user,
  pkgs,
  config,
  languages,
  ...
}:
{
  users.knownUsers = [ "${user}" ];

  users.users.${user} = {
    # required by home-manager
    home = "/Users/${user}";
    shell = pkgs.fish;
    # this is apparently the default uid for the primary user on macOS, but you
    # can get the exact value by running `dscl . -read /Users/<user> UniqueID`
    uid = 501;
  };

  networking = {
    computerName = "Pilatus";
    hostName = "pilatus";
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # define the installed nix package on this host; some tools like nixd rely
  # on this setting being accurate to work correctly
  nix.package = pkgs.lix;

  homebrew = {
    enable = true;
    global.autoUpdate = false;

    casks = [
      "claude-code" # coding agent
      "calibre" # ebook manager
      "ghostty" # terminal
    ];
  };

  environment.systemPackages = with pkgs; [
    # embedded ESP tooling
    ccache # compiler cache for c/c++
    cmake # c build system
    dfu-util # device firmware update USB programmer
    espup # ESP tooling manager
    ldproxy # proxy linker
    ninja # alternative c build system

    gh # github CLI integration
    tmux # terminal multiplexer
    pnpm # javascript package manager

    # macos utilities
    monitorcontrol # external display controller
  ];

  enabledLanguages = with languages; [
    c
    chez
    haskell
    hledger
    idris2
    janet
    java
    javascript
    lean
    lua
    markdown
    nix
    ocaml
    python
    # racket
    rust
    typst
  ];

  # nix-darwin trivia
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}

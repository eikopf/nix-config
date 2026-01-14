{
  self,
  pkgs,
  config,
  languages,
  ...
}:
{
  users.knownUsers = [ "oliver" ];

  users.users.oliver = {
    # required by home-manager
    home = "/Users/oliver";
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
      "claude" # claude code
      "calibre" # ebook manager
      "ghostty" # terminal
      "zen" # browser
    ];

    # https://git.aly.codes/alyraffauf/nixcfg/src/commit/6f122646a3ebaa2e34feb41952b38ecd1bf6019e/hosts/fortree/default.nix#L69
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  environment.systemPackages = with pkgs; [
    # embedded ESP tooling
    ccache # compiler cache for c/c++
    cmake # c build system
    dfu-util # device firmware update USB programmer
    espup # ESP tooling manager
    ldproxy # proxy linker
    ninja # alternative c build system

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

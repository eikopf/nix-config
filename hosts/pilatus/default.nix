{
  user,
  pkgs,
  ...
}:
{
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
      # coding agents
      "claude-code"
      "codex"

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

    qemu # emulator

    # docker tooling
    docker
    orbstack

    gh # github CLI integration
    tmux # terminal multiplexer
    pnpm # javascript package manager

    # macos utilities
    monitorcontrol # external display controller
  ];

  languages = {
    c.enable = true;
    chez.enable = true;
    haskell.enable = true;
    hledger.enable = true;
    idris2.enable = true;
    janet.enable = true;
    java.enable = true;
    javascript.enable = true;
    lean.enable = true;
    lua.enable = true;
    markdown.enable = true;
    nix.enable = true;
    ocaml.enable = true;
    python.enable = true;
    # racket.enable = true;
    rust.enable = true;
    typst.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}

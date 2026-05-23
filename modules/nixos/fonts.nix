{ pkgs, ... }:
{
  # Unicode fallback fonts — covers CJK, emoji, and broad script support.
  # NOTE: Berkeley Mono is used throughout the UI config (sway, waybar, mako,
  # ghostty) but is a commercial font and must be installed out-of-band
  # (e.g. copied to ~/.local/share/fonts after purchase). It is intentionally
  # absent from this file.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
}

# Shell e strumenti da riga di comando.
{ pkgs, unstable, ... }:

{
  programs = {
    zsh = {
      enable = true;
      enableGlobalCompInit = false; # compinit lo fa già .zshrc, una volta sola e in cache
    };
    fzf.keybindings = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      # Shell
      nushell
      carapace
      zoxide
      fzf
      tmux

      # Cerca e leggi
      ripgrep
      ripgrep-all
      jq
      moor
      libqalculate
      socat
      stow
      ffmpeg

      # Archivi
      atool
      unzip
      zip
      unrar

      # Dischi
      exfatprogs
      caligula
      gparted
      kdiskmark
    ]
    ++ (with unstable; [
      yazi
      _7zz # estrazione e compressione in yazi
      mediainfo
      exiftool
      btop-rocm
    ]);
}

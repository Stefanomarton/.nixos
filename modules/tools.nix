# Shell e strumenti da riga di comando.
{ pkgs, unstable, ... }:

{
  programs = {
    zsh.enable = true;
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
      busybox
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
      btop-rocm
    ]);
}

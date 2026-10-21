# Media e svago: musica, video, foto, grafica, registrazione, messaggi, giochi.
{ pkgs, unstable, ... }:

{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-backgroundremoval ];
  };

  environment.systemPackages =
    with pkgs;
    [
      # Musica e video
      spotify
      cmus
      mpv
      vlc

      # Foto, grafica, montaggio
      darktable
      inkscape
      kdePackages.kdenlive
      obs-cli

      # Messaggi e giochi
      ferdium
      prismlauncher
    ]
    ++ [ unstable.altus ];
}

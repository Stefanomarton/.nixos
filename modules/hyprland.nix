# Ambiente grafico: Hyprland con login automatico, audio, bluetooth, strumenti Wayland.
{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  hyprPkgs = inputs.hyprland.packages.${system};
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Patch: il focus al passaggio del mouse sceglie la finestra tiled disegnata sopra (le carte
    # di custom_center2 si sovrappongono). Perde la cache cachix: Hyprland si compila in locale.
    package = hyprPkgs.hyprland.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../assets/hyprland-tiled-hit-order.patch ];
    });
    portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Login automatico: la protezione è la cifratura del disco (dove c'è)
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${config.programs.hyprland.package}/bin/start-hyprland";
        user = username;
      };
      default_session = initial_session;
    };
  };

  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    blueman.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  # Hyprland non esegue l'autostart XDG: blueman e hyprsunset dalle unit dei pacchetti,
  # legate alla sessione e riavviate se cadono (hyprsunset abortisce quando Hyprland esce)
  systemd.packages = [ pkgs.hyprsunset ]; # la sua unit, a cui wantedBy aggiunge solo il collegamento
  systemd.user.services.blueman-applet.wantedBy = [ "graphical-session.target" ];
  systemd.user.services.hyprsunset.wantedBy = [ "graphical-session.target" ];

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "always";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  environment.systemPackages = with pkgs; [
    inputs.pyprland.packages.${system}.pyprland
    kitty
    tofi
    quickshell
    hyprpaper
    hyprsunset
    polkit_gnome
    libnotify

    # Appunti, screenshot, input
    cliphist
    wl-clipboard
    wl-clip-persist
    slurp
    grim
    wtype
    dragon-drop

    # Audio
    pavucontrol
    pamixer
    playerctl

    # File e immagini
    nemo
    imv
    udiskie

    # Portachiavi (gnome-keyring): cambiare la password del portachiavi
    seahorse
  ];
}

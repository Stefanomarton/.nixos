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
    package = hyprPkgs.hyprland;
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
    gammastep
    wallust
    polkit_gnome
    libnotify

    # Appunti, screenshot, input
    cliphist
    wl-clipboard
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
  ];
}

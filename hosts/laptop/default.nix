{ config, pkgs, unstable, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  # User
  users.users.stefanom = {
    isNormalUser = true;
    description = "Stefano Marton";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "input" "uinput" ];
  };

  # Greetd with Hyprland
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "stefanom";
      };
      default_session = initial_session;
    };
  };

  # Laptop-specific: Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Laptop-specific: KDE Connect
  programs.kdeconnect.enable = true;

  # Laptop-specific: TLP battery management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "ondemand";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Laptop-specific: Bluetooth power on boot
  hardware.bluetooth.powerOnBoot = true;

  # Laptop-specific: udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # Laptop-specific: brightness control
  environment.systemPackages = [ pkgs.brightnessctl ];

  # Laptop-specific: ZSH config location
  environment.etc."zshenv".text = ''
    export ZDOTDIR="$HOME"/.config/zsh
    export HISTFILE="$XDG_STATE_HOME"/zsh/history
  '';

  # Laptop-specific: XDG user dirs
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP="$HOME/.desktop"
    DOWNLOAD="$HOME/inbox"
  '';

  # Laptop-specific: systemd timeout
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  # Fonts
  fonts.packages = with pkgs;
    [ julia-mono lexend ]
    ++ builtins.filter lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);

  system.stateVersion = "24.05";
}

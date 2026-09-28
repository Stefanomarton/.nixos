{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.networkmanager.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  programs.kdeconnect.enable = true;

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

  environment.systemPackages = [ pkgs.brightnessctl ];

  system.stateVersion = "24.05";
}

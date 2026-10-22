# Portatili: rete con NetworkManager, batteria con TLP, luminosità, dock Thunderbolt e tasto di accensione.
{ pkgs, username, ... }:

{
  networking.networkmanager.enable = true;
  users.users.${username}.extraGroups = [ "networkmanager" ];

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

  # Il tasto della dock HP arriva come tasto di accensione: una pressione breve non spegne
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Dispositivi Thunderbolt (dock HP): senza autorizzazione passano solo i monitor, non USB e rete.
  # Una volta per dock: boltctl enroll --policy auto <uuid da boltctl list>
  services.hardware.bolt.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];
}

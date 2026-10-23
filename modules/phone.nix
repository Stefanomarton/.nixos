# Telefono: KDE Connect (notifiche, file), scrcpy (schermo), adb.
{ config, pkgs, ... }:

{
  programs.kdeconnect.enable = true;

  # Il demone parte solo dall'autostart XDG, che Hyprland non esegue
  systemd.user.services.kdeconnectd = {
    description = "KDE Connect";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${config.programs.kdeconnect.package}/bin/kdeconnectd";
      Restart = "on-failure";
    };
  };

  environment.systemPackages = with pkgs; [
    scrcpy
    android-tools
  ];
}

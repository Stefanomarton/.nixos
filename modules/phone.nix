# Telefono: KDE Connect (notifiche, file), scrcpy (schermo), adb.
{ pkgs, ... }:

{
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    scrcpy
    android-tools
  ];
}

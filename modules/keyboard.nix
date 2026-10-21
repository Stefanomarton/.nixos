# Tastiera e mouse: kmonad (rimappature) e solaar (periferiche Logitech).
{ pkgs, username, ... }:

{
  # /dev/uinput scrivibile dal gruppo uinput (per kmonad): crea il gruppo e carica il modulo
  hardware.uinput.enable = true;

  users.users.${username}.extraGroups = [
    "input"
    "uinput"
  ];

  environment.systemPackages = with pkgs; [
    kmonad
    solaar
  ];
}

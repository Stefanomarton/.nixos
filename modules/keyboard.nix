# Tastiera e mouse: kmonad (rimappature) e solaar (periferiche Logitech).
{ pkgs, username, ... }:

{
  # Let kmonad & friends write to /dev/uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  users.users.${username}.extraGroups = [
    "input"
    "uinput"
  ];

  environment.systemPackages = with pkgs; [
    kmonad
    solaar
  ];
}

# laptop: portatile personale (Intel).
{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base.nix
    ../../modules/hyprland.nix
    ../../modules/theme.nix
    ../../modules/keyboard.nix
    ../../modules/tools.nix
    ../../modules/editors.nix
    ../../modules/dev.nix
    ../../modules/documents.nix
    ../../modules/web.nix
    ../../modules/portable.nix

    ../../modules/homelab.nix
    ../../modules/phone.nix
    ../../modules/remote.nix
    ../../modules/maker.nix
    ../../modules/media.nix
  ];

  system.stateVersion = "24.05";
}

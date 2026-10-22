# Aspetto: font, tema stylix (black-metal-nile). Notifiche: widget quickshell
# ~/.config/hypr/widgets/notifications (dotfiles), non dunst.
{
  pkgs,
  lib,
  inputs,
  username,
  ...
}:

{
  fonts.packages =
    with pkgs;
    [
      julia-mono
      lexend
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  home-manager.users.${username} =
    { config, ... }:
    {
      imports = [ inputs.stylix.homeModules.stylix ];

      stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";
        # inert under home-manager.useGlobalPkgs, and silences its warning
        overlays.enable = false;
        # Niente image: lo sfondo lo mette hyprpaper con ~/.config/hypr/hyprpaper.conf (dotfile)
        base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-nile.yaml";
        targets = {
          gtk.enable = true;
          zathura.enable = true;
          kitty.enable = true;
          kitty.variant256Colors.enable = true;
          hyprland.enable = true;
          nushell.enable = true;
          yazi.enable = true;
        };
        cursor = {
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 18;
        };
      };
    };
}

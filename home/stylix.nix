{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    # inert under home-manager.useGlobalPkgs, and silences its warning
    overlays.enable = false;
    image = ./wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-nile.yaml";
    targets = {
      gtk.enable = true;
      zathura.enable = true;
      kitty.enable = true;
      kitty.variant256Colors.enable = true;
      hyprland.enable = true;
      hyprpaper.enable = true;
      nushell.enable = true;
      yazi.enable = true;
    };
    # Set the Adwaita cursor
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 18; # You can adjust the size to your preference (e.g., 16, 24, 32)
    };
  };

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          mouse_left_click = [
            "do_action"
            "close_current"
          ];
        };
      };
    };

  };

}

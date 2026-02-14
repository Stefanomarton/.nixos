{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
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
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 45.1854;
    longitude = 9.1553;
    settings = {
      general = {
        brightness-day = 1.0;
        brightness-night = 0.6;
        adjustment-method = "wayland";
      };
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 2;
        mouse_left_click = [ "do_action" "close_current" ];
      };
    };
  };
}

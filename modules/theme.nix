# Aspetto: font, tema stylix (black-metal-nile), notifiche dunst.
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
        image = ../assets/wallpaper.png;
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
        cursor = {
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 18;
        };
      };

      services.dunst = {
        enable = true;
        settings = {
          global = {
            follow = "none";
            monitor = 0; # sempre sul principale: DP-1 sul desktop (dunst 1.13 vuole il numero, non il nome)
            origin = "top-center";
            offset = "(0, 40)";
            width = 800;
            font = lib.mkForce "${config.stylix.fonts.sansSerif.name} 16"; # più grande dei popup stylix (10)
            padding = 16;
            horizontal_padding = 20;
            gap_size = 8;
            max_icon_size = 64;
            notification_limit = 3;
            indicate_hidden = true;
            stack_duplicates = true;
            hide_duplicate_count = false;
            idle_threshold = 120; # lontano dal PC: non scadono
            history_length = 100;
            sticky_history = true;
            frame_width = 2;
            mouse_left_click = "do_action, close_current";
            mouse_right_click = "close_current";
            mouse_middle_click = "context";
            dmenu = "${pkgs.tofi}/bin/tofi --prompt-text azione: "; # menu delle azioni (default: /usr/bin/dmenu, assente)
          };
          urgency_low.timeout = 3;
          urgency_normal.timeout = 8;
          urgency_critical.timeout = 0; # resta finché la chiudi

          # Regole: le sezioni escono in ordine alfabetico e dunst applica l'ultima che combacia.
          claude_attende = {
            appname = "kitty";
            body = "*needs your input*";
            urgency = "critical";
          };
          # Telefono (KDE Connect): solo cronologia, tranne chiamate e SMS. Nomi da verificare col telefono.
          telefono = {
            appname = "*[Cc]onnect*";
            skip_display = true;
          };
          telefono_chiamate = {
            appname = "*[Cc]onnect*";
            summary = "*[Cc]all*";
            skip_display = false;
          };
          telefono_chiamate_it = {
            appname = "*[Cc]onnect*";
            summary = "*hiamat*";
            skip_display = false;
          };
          telefono_messaggi = {
            appname = "*[Cc]onnect*";
            summary = "Messag*";
            skip_display = false;
          };
          telefono_sms = {
            appname = "*[Cc]onnect*";
            summary = "*SMS*";
            skip_display = false;
          };
        };
      };
    };
}

{ pkgs, unstable, kimi, claude-code, ... }:

let
  mytexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full beamertheme-arguelles;
  };
in {
  programs = {

    zsh.enable = true;

    firefox.enable = true;

    chromium.enable = true;

    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    fzf.keybindings = true;

  };

  xdg.mime.defaultApplications = { "application/pdf" = "sioyek.desktop"; };

  environment.systemPackages = with pkgs;
    [
      # Editors
      neovim
      neovide
      emacs30-pgtk
      emacsPackages.jinx
      emacs-lsp-booster
      antigravity

      # Spell checking
      enchant
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science it ]))
      hunspell
      hunspellDicts.en_US
      hunspellDicts.it_IT

      # Documents
      plantuml
      mermaid-cli
      mytexlive

      # Terminal
      kitty
      zoxide
      fzf
      nushell
      carapace

      # Git
      git
      lazygit
      gh
      delta

      # Tools
      stow
      exfatprogs
      socat
      libqalculate
      ripgrep
      ripgrep-all
      jq
      busybox
      slurp
      grim
      atool
      caligula
      moor
      kdiskmark
      freerdp

      # Audio
      easyeffects
      pavucontrol
      pamixer
      playerctl
      cmus
      mpv

      # Productivity
      anki
      sioyek
      zotero
      obsidian
      anydesk
      pdfpc

      # Chemistry
      avogadro2
      fityk
      marvin

      # Creative
      jre_minimal
      inkscape
      ipe
      solaar
      kdePackages.kdenlive
      freecad
      prusa-slicer
      orca-slicer

      # Social
      ferdium

      # Desktop environment
      vscode
      kimi.packages.${pkgs.system}.kimi-cli
      claude-code.packages.${pkgs.system}.claude-code
            wallust
      imv
      tofi
      cliphist
      pyprland
      wl-clipboard
      kmonad
      polkit_gnome
      hyprpaper
      gammastep
      vlc
      dragon-drop
      wireguard-tools
      libnotify
      quickshell
      wtype
      gparted
      spotify
      buku
      nemo

      # Files
      unzip
      zip
      unrar

      # Programming
      gnumake
      tree-sitter
      cmake
      gcc
      python3
      pyright
      clang
      nixfmt-classic
      cpio
      meson
      hyprwayland-scanner
      hyprcursor
      taplo
      nodejs_24
      shfmt

      # Embedded/QMK
      qmk
      pkgsCross.avr.buildPackages.gcc
      avrdude
      pico-sdk
      picotool

      # VM
      virglrenderer
      remmina
      moonlight-qt
      rpi-imager

      # LSP
      nixd
    ] ++ (with unstable; [
      darktable
      gemini-cli
      claude-code
      yazi
      btop-rocm
      libreoffice-fresh
      altus
      chromium
      typst
      typstyle
      tinymist
      supersonic-wayland
      nextcloud-client
    ]);
}

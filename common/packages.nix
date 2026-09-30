{
  pkgs,
  unstable,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  mytexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full beamertheme-arguelles;
  };
in
{

  programs = {

    zsh.enable = true;

    chromium.enable = true;

    kdeconnect.enable = true;

    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    fzf.keybindings = true;

    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-backgroundremoval ];
    };

  };

  services.netbird = {
    package = unstable.netbird;
    clients.wt0 = {

      # Port used to listen to wireguard connections
      port = 51821;

      # Set this to true if you want the GUI client
      ui.enable = false;

      # This opens ports required for direct connection without a relay
      openFirewall = true;

      # This opens necessary firewall ports in the Netbird client's network interface
      openInternalFirewall = true;
    };
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
    defaultEditor = true;
    startWithGraphical = true;
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "sioyek.desktop";
  };

  environment.systemPackages =
    with pkgs;
    [
      inputs.pyprland.packages.${system}.pyprland
      # Editors
      inputs.neovim.packages.${system}.default
      emacs30-pgtk
      emacsPackages.jinx

      emacs-lsp-booster

      # Spell checking
      enchant
      (aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
          en-science
          it
        ]
      ))
      hunspell
      hunspellDicts.en_US
      hunspellDicts.it_IT

      # Documents
      plantuml
      mermaid-cli
      mytexlive
      ffmpeg
      qpdf

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

      scrcpy
      hyprsunset

      # Tools
      stow
      exfatprogs
      socat
      libqalculate
      zathura
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
      obs-cli

      # Audio
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
      logseq
      pdfpc
      tmux

      # Creative
      jre_minimal
      inkscape
      ipe
      solaar
      kdePackages.kdenlive
      freecad
      prusa-slicer
      orca-slicer
      clickup

      # Social
      ferdium

      # Desktop environment
      vscode
      inputs.claude-code.packages.${system}.claude-code
      wallust
      imv
      tofi
      cliphist
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
      # # rust
      cargo
      bun
      rustc
      rustfmt
      clippy
      rust-analyzer
      marksman
      android-tools

      gnumake
      tree-sitter
      cmake
      gcc
      python3
      pyright
      clang
      nixfmt
      cpio
      meson
      hyprwayland-scanner
      hyprcursor
      taplo
      nodejs_24
      shfmt

      supabase-cli
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
      prismlauncher

      # LSP
      nixd
      darktable
    ]
    ++ (with unstable; [
      teams-for-linux
      anydesk
      herdr
      claude-agent-acp
      yazi
      btop-rocm
      libreoffice
      altus
      chromium
      typst
      typstyle
      tinymist
      nextcloud-client
      neovide
      go-hass-agent
      pandoc
      thunderbird
      bitwarden-desktop
      ticktick
    ]);
}

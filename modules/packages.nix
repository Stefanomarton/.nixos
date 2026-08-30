{
  pkgs,
  unstable,
  kimi,
  claude-code,
  neovim,
  pyprland,
  ...
}:

let
  mytexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full beamertheme-arguelles;
  };
in
{

  programs = {

    niri.enable = true;

    zsh.enable = true;

    firefox.enable = true;

    chromium.enable = true;

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

  services.hyprwhspr-rs = {
    enable = true;
    package = pkgs.hyprwhspr-rs.override {
      # to optimize build time you can skip enabling cudaSupport for one of these two
      # for whisper do whisper-cpp, for NVIDIA Parakeet do onnxruntime
      whisper-cpp = pkgs.whisper-cpp.override { rocmSupport = true; };
      onnxruntime = pkgs.onnxruntime.override { rocmSupport = true; };
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
      pyprland.packages.${pkgs.system}.pyprland
      # Editors
      neovim.packages.${pkgs.system}.default
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
      kimi.packages.${pkgs.system}.kimi-cli
      claude-code.packages.${pkgs.system}.claude-code
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
      anydesk
      herdr

      hyprwhspr-rs
      claude-agent-acp
      yazi
      btop-rocm
      libreoffice-fresh
      altus
      chromium
      typst
      typstyle
      tinymist
      nextcloud-client
      neovim
      neovide
      go-hass-agent
      pandoc
      thunderbird
      bitwarden-desktop
      ticktick
      morgen
      pyprland
    ]);
}

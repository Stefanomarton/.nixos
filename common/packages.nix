{ config, pkgs, unstable, inputs, ... }:
let
  mytexlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full beamertheme-arguelles;
  };
in {

  services.flatpak.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  programs.zsh.enable = true;
  programs.firefox = { enable = true; };

  programs.chromium.enable = true;

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # services.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [

    #Editors
    neovim
    neovide
    claude-code
    # auctex
    # emacsPackages.auctex
    emacs30-pgtk
    emacsPackages.jinx
    emacs-lsp-booster
    enchant
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science it ]))
    hunspell
    hunspellDicts.en_US
    hunspellDicts.it_IT
    plantuml
    mermaid-cli
    mytexlive

    # Terminal and Shell
    kitty
    zoxide
    fzf
    nushell
    carapace

    # Programs
    gparted

    spotify
    buku
    kdePackages.kdenlive
    freecad
    wtype

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

    # Chemistry
    pdfpc

    # Audio
    easyeffects
    pavucontrol
    pamixer
    playerctl
    cmus
    mpv

    # Productivity
    anki
    zathura
    sioyek
    zotero
    obsidian
    anydesk
    anki

    #chemistry
    avogadro2
    fityk
    marvin

    jre_minimal
    inkscape
    ipe
    solaar

    # social
    ferdium

    # DE
    vscode
    wallust
    imv
    tofi
    eww
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

    #3DPrinting
    prusa-slicer
    orca-slicer

    # Files
    unzip
    zip
    unrar
    atool

    # Appearance
    nemo

    # Programming and compilers
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
    qmk
    pkgsCross.avr.buildPackages.gcc
    avrdude
    pico-sdk
    picotool

    # VM
    OVMFFull
    swtpm
    virt-viewer
    virglrenderer
    looking-glass-client
    remmina
    moonlight-qt
    rpi-imager

    # GPU
    nvtopPackages.amd

    #LSP
    nixd

  ])

    ++ (with unstable; [
      darktable
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

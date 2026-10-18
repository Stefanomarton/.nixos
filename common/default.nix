{
  config,
  pkgs,
  lib,
  inputs,
  unstable,
  hostname,
  username,
  ...
}:

{
  imports = [
    ./system.nix
    ./desktop.nix
    ./packages.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    description = "Stefano Marton";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
    ];
  };

  # Greetd with Hyprland
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${config.programs.hyprland.package}/bin/start-hyprland";
        user = username;
      };
      default_session = initial_session;
    };
  };

  # Let kmonad & friends write to /dev/uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # cpm installs claude-<profile> wrappers into ~/.local/bin
  environment.localBinInPath = true;

  environment.etc."zshenv".text = ''
    export ZDOTDIR="$HOME"/.config/zsh
    export HISTFILE="$XDG_STATE_HOME"/zsh/history
  '';

  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP="$HOME/.desktop"
    DOWNLOAD="$HOME/inbox"
  '';

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  fonts.packages =
    with pkgs;
    [
      julia-mono
      lexend
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit unstable; };
    users.${username}.imports = [
      inputs.stylix.homeModules.stylix
      ../home
      ../home/stylix.nix
    ];
  };
}

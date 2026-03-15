{ nixpkgs, nixpkgs-unstable, home-manager, stylix, ... }@inputs:

{ system ? "x86_64-linux", hostname, username, modules ? [ ]
, extraHomeModules ? [ ], }:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in nixpkgs.lib.nixosSystem {
  inherit system pkgs;

  modules = [
    # Core system modules
    ../modules/core
    ../modules/graphical
    ../modules/packages.nix
    ../modules/virtualization.nix

    # Home-manager integration
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.${username} = { ... }: {
          imports = [ stylix.homeModules.stylix ../home ../home/stylix.nix ]
            ++ extraHomeModules;
        };
        extraSpecialArgs = { inherit unstable; };
      };
    }
  ] ++ modules;

  specialArgs = {
    inherit unstable;
  } // (builtins.removeAttrs inputs ["nixpkgs" "nixpkgs-unstable" "home-manager" "stylix"]);
}

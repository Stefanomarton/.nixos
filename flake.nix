{
  description = "NixOS configuration for laptop and desktop";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-25.11";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, determinate, ... }@inputs:
    let
      mkHost = import ./lib/mkHost.nix {
        inherit nixpkgs nixpkgs-unstable home-manager stylix;
      };
    in {
      nixosConfigurations = {
        laptop = mkHost {
          hostname = "laptop";
          username = "stefanom";
          modules = [
            ./hosts/laptop
          ];
        };

        desktop = mkHost {
          hostname = "desktop";
          username = "sm";
          modules = [
            determinate.nixosModules.default
            ./hosts/desktop
          ];
        };
      };
    };
}

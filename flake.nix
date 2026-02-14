{
  description = "A simple NixOS flake";

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

  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, determinate, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # overlays = [ ... ];  # if you have overlays, put them here
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {

      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system pkgs;

          modules = [
            ./hosts/laptop/configuration.nix
            ./common/packages.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "backup";
              home-manager.useUserPackages = true;
              home-manager.users.stefanom = { ... }: {
                imports = [
                  stylix.homeModules.stylix
                  ./common/stylix.nix

                ];
              };
            }
          ];

          specialArgs = {
            inherit unstable;
            inherit inputs;
          };
        };

        desktop = lib.nixosSystem {
          inherit system pkgs;

          modules = [
            determinate.nixosModules.default
            ./hosts/desktop/configuration.nix
            ./common/packages.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = false;
                backupFileExtension = "backup";
                useUserPackages = true;
                users.sm = { ... }: {
                  imports = [ stylix.homeModules.stylix ./common/stylix.nix ];
                };
                extraSpecialArgs = {
                  inherit inputs;
                  inherit unstable;
                };
              };
            }
          ];

          specialArgs = {
            inherit unstable;
            inherit inputs;
          };
        };
      };
    };
}

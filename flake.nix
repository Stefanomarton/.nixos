{
  description = "NixOS configuration for laptop and desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-26.05";
    kimi.url = "github:MoonshotAI/kimi-cli";
    claude-code.url = "github:sadjow/claude-code-nix";
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    hyprland.url = "github:hyprwm/Hyprland";
    pyprland.url = "github:hyprland-community/pyprland";
    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      stylix,
      kimi,
      claude-code,
      kmonad,
      neovim,
      hyprland,
      pyprland,
      openlogi,
      ...
    }@inputs:
    let
      mkHost = import ./lib/mkHost.nix {
        inherit
          nixpkgs
          nixpkgs-unstable
          home-manager
          stylix
          kimi
          claude-code
          kmonad
          neovim
          hyprland
          pyprland
          openlogi
          ;
      };
    in
    {

      nixosConfigurations = {
        laptop = mkHost {
          hostname = "laptop";
          username = "stefanom";
          modules = [ ./hosts/laptop ];
        };

        desktop = mkHost {
          hostname = "desktop";
          username = "sm";
          modules = [
            ./hosts/desktop
            kmonad.nixosModules.default
            openlogi.nixosModules.default
          ];
        };
      };
    };
}

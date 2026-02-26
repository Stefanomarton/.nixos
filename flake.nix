{
  description = "NixOS configuration for laptop and desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-25.11";
    kimi.url = "github:MoonshotAI/kimi-cli";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, kimi
    , claude-code, ... }@inputs:
    let
      mkHost = import ./lib/mkHost.nix {
        inherit nixpkgs nixpkgs-unstable home-manager stylix kimi claude-code;
      };
    in {
      nixosConfigurations = {
        laptop = mkHost {
          hostname = "laptop";
          username = "stefanom";
          modules = [ ./hosts/laptop ];
        };

        desktop = mkHost {
          hostname = "desktop";
          username = "sm";
          modules = [ ./hosts/desktop ];
        };
      };
    };
}

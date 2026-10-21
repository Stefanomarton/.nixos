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
    cpm.url = "github:JakubKontra/claude-profile-manager";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    hyprland.url = "github:hyprwm/Hyprland";
    pyprland.url = "github:hyprland-community/pyprland";
    tasks.url = "git+https://github.com/Stefanomarton/tasks?ref=feat/v0";
    reshiki = {
      url = "github:Ameyanagi/ReShiki";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";

      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-39.8.10" ];
      };
      pkgsFrom =
        source:
        import source {
          inherit system;
          config = nixpkgsConfig;
        };

      # Every host gets common/ + its own hosts/<hostname>/.
      mkHost =
        {
          hostname,
          username,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = pkgsFrom nixpkgs;
          specialArgs = {
            inherit inputs hostname username;
            unstable = pkgsFrom nixpkgs-unstable;
          };
          modules = [
            ./common
            ./hosts/${hostname}
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        laptop = mkHost {
          hostname = "laptop";
          username = "stefanom";
        };

        desktop = mkHost {
          hostname = "desktop";
          username = "sm";
          extraModules = [ inputs.openlogi.nixosModules.default ];
        };
      };
    };
}

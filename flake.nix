{
  description = "NixOS di Stefano: desktop, laptop e tm-laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Solo tm-laptop: disco cifrato dichiarativo e Secure Boot
    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
    cpm = {
      url = "github:JakubKontra/claude-profile-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Senza follows: così resta valida la cache precompilata di hyprland.cachix.org
    hyprland.url = "github:hyprwm/Hyprland";
    pyprland = {
      url = "github:hyprland-community/pyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    tasks = {
      url = "git+https://github.com/Stefanomarton/tasks?ref=feat/v0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hard fork di agent-deck (privato): pacchetto e modifiche nostre; shallow, la storia è grande
    agent-deck = {
      url = "git+https://github.com/Stefanomarton/agent-deck?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    reshiki = {
      url = "github:Ameyanagi/ReShiki";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgsFrom =
        source:
        import source {
          inherit system;
          config.allowUnfree = true;
        };

      # Ogni host è hosts/<hostname>/default.nix, che importa le feature che usa da modules/.
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = pkgsFrom nixpkgs;
          specialArgs = {
            inherit inputs hostname;
            username = "sm";
            unstable = pkgsFrom nixpkgs-unstable;
          };
          modules = [ ./hosts/${hostname} ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs [
        "desktop"
        "laptop"
        "tm-laptop"
      ] mkHost;
    };
}

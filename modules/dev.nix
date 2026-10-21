# Sviluppo: git, linguaggi, LSP, Claude Code.
{
  pkgs,
  unstable,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # cpm installs claude-<profile> wrappers into ~/.local/bin
  environment.localBinInPath = true;

  environment.systemPackages =
    with pkgs;
    [
      # Agenti
      inputs.claude-code.packages.${system}.claude-code
      inputs.cpm.packages.${system}.default

      # Git
      git
      lazygit
      gh
      delta

      # Build
      gnumake
      cmake
      meson
      gcc
      clang
      cpio
      tree-sitter
      hyprwayland-scanner
      hyprcursor

      # Linguaggi
      python3
      nodejs_24
      bun
      typescript
      cargo
      rustc
      jre_minimal
      supabase-cli

      # LSP e formattatori
      nixd
      nixfmt
      rust-analyzer
      rustfmt
      clippy
      pyright
      typescript-language-server # LSP per il plugin typescript-lsp di Claude Code
      marksman
      taplo
      shfmt
    ]
    ++ [ unstable.herdr ];
}

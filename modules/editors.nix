# Editor: Emacs (demone, editor predefinito), Neovim nightly, VS Code, correttori ortografici.
{
  pkgs,
  unstable,
  inputs,
  ...
}:

{
  services.emacs = {
    enable = true;
    package = unstable.emacs31-pgtk;
    defaultEditor = true;
    startWithGraphical = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      inputs.neovim.packages.${stdenv.hostPlatform.system}.default
      emacsPackages.jinx
      emacs-lsp-booster
      vscode

      # Correttori ortografici (en, it)
      enchant
      (aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
          en-science
          it
        ]
      ))
      hunspell
      hunspellDicts.en_US
      hunspellDicts.it_IT
    ]
    ++ (with unstable; [
      neovide
      antigravity-ide
    ]);
}

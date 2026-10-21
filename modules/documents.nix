# Documenti e studio: LaTeX, Typst, Pandoc, PDF, ufficio, note, bibliografia, chimica.
{
  pkgs,
  unstable,
  inputs,
  ...
}:

let
  texlive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full beamertheme-arguelles;
  };
in
{
  xdg.mime.defaultApplications."application/pdf" = "sioyek.desktop";

  environment.systemPackages =
    with pkgs;
    [
      # Scrittura
      texlive
      plantuml
      mermaid-cli
      qpdf
      ipe
      inputs.reshiki.packages.${stdenv.hostPlatform.system}.default # strutture chimiche e schemi di reazione

      # Lettura e presentazioni
      sioyek
      zathura
      pdfpc

      # Note, studio, bibliografia
      obsidian
      logseq
      zotero
      anki
    ]
    ++ (with unstable; [
      typst
      typstyle
      tinymist
      pandoc
      libreoffice
    ]);
}

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
  xdg.mime.defaultApplications = {
    "application/pdf" = "sioyek.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      "ai.storyteller.wordcraft.desktop";
    "application/vnd.oasis.opendocument.text" = "ai.storyteller.wordcraft.desktop";
    "application/rtf" = "ai.storyteller.wordcraft.desktop";
  };

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
      zotero
      anki
    ]
    ++ (with unstable; [
      typst
      typstyle
      tinymist
      pandoc
      wordcraft # testi; export PDF con wordcraft-cli convert
    ]);
}

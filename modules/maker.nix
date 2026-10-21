# Maker: CAD e stampa 3D, firmware per tastiere (QMK) e microcontrollori.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # CAD e stampa 3D
    freecad
    prusa-slicer
    orca-slicer

    # QMK, AVR, Raspberry Pi Pico
    qmk
    pkgsCross.avr.buildPackages.gcc
    avrdude
    pico-sdk
    picotool
    rpi-imager
  ];
}

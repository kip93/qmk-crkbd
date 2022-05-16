{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "nix-format" ''
  #!${bash}/bin/bash
  set -eu
  ${findutils}/bin/find '${toString ../.}' -type f -name '*.nix' -not -path '${toString ../QMK}/*' |
    ${findutils}/bin/xargs ${nixpkgs-fmt}/bin/nixpkgs-fmt --check
''

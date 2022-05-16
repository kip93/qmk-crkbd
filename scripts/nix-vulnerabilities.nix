{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "nix-vulnerabilities" ''
  #!${bash}/bin/bash
  set -eu
  ${findutils}/bin/find '${toString ../.}' -type f -name '*.nix' -not -path '${toString ../QMK}/*' |
    ${findutils}/bin/xargs ${vulnix}/bin/vulnix -f
''

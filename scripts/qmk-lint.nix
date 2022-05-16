{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "qmk-lint" ''
  #!${bash}/bin/bash
  set -eu
  cd '${toString ../.}'
  ${nix}/bin/nix-shell --run lint
''

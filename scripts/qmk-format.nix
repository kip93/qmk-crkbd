{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "qmk-format" ''
  #!${bash}/bin/bash
  set -eu
  cd '${toString ../.}'
  ${nix}/bin/nix-shell --run format
  ${git}/bin/git diff --exit-code --name-only
''

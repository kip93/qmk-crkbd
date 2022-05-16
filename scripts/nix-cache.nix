{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "nix-cache" ''
  #!${bash}/bin/bash
  set -eu
  # shellcheck disable=SC2016
  ${findutils}/bin/find '${toString ../.}' -type f -name '*.nix' -a \( -not -path '${toString ../QMK}/*' -o -path '${toString ../QMK}/shell.nix' \) |
    ${findutils}/bin/xargs -I{} ${bash}/bin/bash -c '
      set -eu
      if [ "$(${nix}/bin/nix-instantiate --eval -E "builtins.hasAttr \"shellHook\" ((import <nixpkgs> { }).callPackage \"{}\" { })")" == "true" ] ; then
        ${nix}/bin/nix-build "{}" --no-out-link -A inputDerivation
      else
        ${nix}/bin/nix-build "{}" --no-out-link
      fi
    ' | ${cachix}/bin/cachix push "''${1}"
''

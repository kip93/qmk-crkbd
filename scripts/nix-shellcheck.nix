{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "nix-shellcheck" ''
  #!${bash}/bin/bash
  set -eu
  # shellcheck disable=SC2016
  ${findutils}/bin/find '${toString ../shell.nix}' '${toString ./.}' -type f -name '*.nix' |
    ${findutils}/bin/xargs -I{} sh -c '
      set -eu
      if [ "$(${nix}/bin/nix-instantiate --eval -E "builtins.hasAttr \"shellHook\" ((import <nixpkgs> { }).callPackage \"{}\" { })")" == "true" ] ; then
        ${nix}/bin/nix-build "{}" --no-out-link -A inputDerivation >/dev/null
      else
        ${nix}/bin/nix-build "{}" --no-out-link >/dev/null
      fi
      ${nix}/bin/nix-instantiate --eval -E "
        let
          pkgs = import <nixpkgs> { };
          drv = pkgs.callPackage \"{}\" { };
        in
        if (builtins.hasAttr \"shellHook\" drv) then
          (\"#!${bash}/bin/bash\n\" + drv.shellHook)
        else
          (builtins.readFile drv)
      " | \
        ${coreutils}/bin/tail -c +2 | \
        ${coreutils}/bin/head -c -2 | \
        ${findutils}/bin/xargs -0 ${coreutils}/bin/printf | \
        ${gnused}/bin/sed "s/\\\\\\$/$/g" | (
          ${shellcheck}/bin/shellcheck -C - &&
            ${coreutils}/bin/printf "\033[1;32m%s\033[0m\n" "{}" ||
            (${coreutils}/bin/printf "\033[1;31m%s\033[0m\n" "{}" ; exit 1)
        )
    '
''

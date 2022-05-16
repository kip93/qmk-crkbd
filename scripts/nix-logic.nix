{ pkgs ? import <nixpkgs> { } }:  # TODO Uncomment some stuff
with pkgs; writeScript "nix-logic" ''
  #!${bash}/bin/bash
  set -eu
  ${coreutils}/bin/printf '# \033[3mStart\033[0m ########################################################################\n' >&2
  WORKDIR="$(${coreutils}/bin/mktemp -d)"
  export WORKDIR
  OUTPUT="$(${coreutils}/bin/mktemp -d)"
  export OUTPUT
  trap 'XC=$?; ${coreutils}/bin/rm -rf -- "''${WORKDIR}" "''${OUTPUT}"; exit ''${XC}' EXIT INT QUIT TERM
  ${coreutils}/bin/printf '\033[3mWorking directory : %s\033[0m\n' "''${WORKDIR}" >&2
  ${coreutils}/bin/printf '\033[3mOutputs directory : %s\033[0m\n' "''${OUTPUT}"  >&2
  ${coreutils}/bin/printf '\n' >&2

  # shellcheck disable=SC2016
  (
    cd '${toString ../QMK}' &&
    ${nix}/bin/nix-shell --pure --run 'qmk list-keyboards' 2>/dev/null | ${coreutils}/bin/shuf | ${findutils}/bin/xargs -P"$(${coreutils}/bin/nproc --all)" -I{} ${bash}/bin/bash -c '
      set -eu

      OUTPUT="''${OUTPUT}/$(${coreutils}/bin/printf %s "{}" | ${gnused}/bin/sed -r "s|/|_|g")"
      WORKDIR="''${WORKDIR}/$(${coreutils}/bin/printf %s "{}" | ${gnused}/bin/sed -r "s|/|_|g")"

      ${coreutils}/bin/mkdir -p "''${WORKDIR}"
      trap '"'"'
        XC=$?;
        ${coreutils}/bin/printf "\033[3;%sm%s\033[0m\n" "$([ ''${XC} -eq 0 ] && ${coreutils}/bin/printf 32 || ${coreutils}/bin/printf 31)" "{}";
        [ ''${XC} -ne 0 ] && ${coreutils}/bin/cat "''${OUTPUT}" >&2;
        ${coreutils}/bin/rm -rf -- "''${WORKDIR}";
        exit ''${XC};
      '"'"' EXIT INT QUIT TERM
      ${coreutils}/bin/cp '"'"'${toString ../shell.nix}'"'"' "''${WORKDIR}"
      ${gnused}/bin/sed -i -E '"'"'s|\bKEYBOARD\b\s*=\s*".+?"\s*;|KEYBOARD = "{}";|'"'"' "''${WORKDIR}/shell.nix"
      cd "''${WORKDIR}"

      # ${coreutils}/bin/printf \
      #   "# \033[3mWelcome\033[0m ============================================================================================= #\n" \
      #   >>"''${OUTPUT}"
      # ${nix}/bin/nix-shell --pure --run welcome >>"''${OUTPUT}" 2>&1

      # ${coreutils}/bin/printf \
      #   "# \033[3mHelp\033[0m ================================================================================================ #\n" \
      #   >>"''${OUTPUT}"
      # MANPAGER=${coreutils}/bin/cat ${nix}/bin/nix-shell --run help >>"''${OUTPUT}" 2>&1

      ${coreutils}/bin/printf \
        "# \033[3mInit\033[0m ================================================================================================ #\n" \
        >>"''${OUTPUT}"
      ${nix}/bin/nix-shell --pure --run init >>"''${OUTPUT}" 2>&1
      ${coreutils}/bin/test -d "''${WORKDIR}/.git"
      ${coreutils}/bin/test -d "''${WORKDIR}/QMK"
      ${coreutils}/bin/test -f "''${WORKDIR}/shell.nix"
      ${coreutils}/bin/test -d "''${WORKDIR}/keymap"
      ${coreutils}/bin/test -f "''${WORKDIR}/keymap/keymap.c"

      ${coreutils}/bin/printf \
        "# \033[3mSetup\033[0m =============================================================================================== #\n" \
        >>"''${OUTPUT}"
      ${nix}/bin/nix-shell --pure --run setup >>"''${OUTPUT}" 2>&1  # No root access, but not needed since we will not be flashing

      # ${coreutils}/bin/printf \
      #   "# \033[3mFormat\033[0m ============================================================================================== #\n" \
      #   >>"''${OUTPUT}"
      # ${nix}/bin/nix-shell --pure --run format >>"''${OUTPUT}" 2>&1

      # ${coreutils}/bin/printf \
      #   "# \033[3mLint\033[0m ================================================================================================ #\n" \
      #   >>"''${OUTPUT}"
      # ${nix}/bin/nix-shell --pure --run lint >>"''${OUTPUT}" 2>&1

      ${coreutils}/bin/printf \
        "# \033[3mCompile\033[0m ============================================================================================= #\n" \
        >>"''${OUTPUT}"
      ${nix}/bin/nix-shell --pure --run compile >>"''${OUTPUT}" 2>&1

      # ${coreutils}/bin/printf \
      #   "# \033[3mFlash\033[0m =============================================================================================== #\n" \
      #   >>"''${OUTPUT}"
      # ${nix}/bin/nix-shell --pure --run flash >>"''${OUTPUT}" 2>&1  # Cannot flash since there is no keyboard attached

      # ${coreutils}/bin/printf \
      #   "# \033[3mClean\033[0m =============================================================================================== #\n" \
      #   >>"''${OUTPUT}"
      # ${nix}/bin/nix-shell --pure --run clean >>"''${OUTPUT}" 2>&1

      ${coreutils}/bin/rm -rf -- "''${OUTPUT}"
    ' ;
  )
''

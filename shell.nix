/**********************************************************************************************************************\
* Portable bash shell with all dependencies and scripts to work with QMK.                                              *
*                                                                                                                      *
* Copyright 2022  Leandro Emmanuel Reina Kiperman <@kip93>                                                             *
*                                                                                                                      *
* This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public    *
* License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later *
* version.                                                                                                             *
*                                                                                                                      *
* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied   *
* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more         *
* details.                                                                                                             *
*                                                                                                                      *
* You should have received a copy of the GNU General Public License along with this program. If not, see               *
* <http://www.gnu.org/licenses/>.                                                                                      *
\**********************************************************************************************************************/

{ pkgs ? import <nixpkgs> {} }: let
  #################
  # Configuration #
  #################

  # Name of the folder inside the QMK submodule
  # e.g., `ergodox_ez`, `0xcb/1337`, et cetera
  KEYBOARD = "crkbd";
  # The keymap link to be created inside of QMK/<KEYBOARD>/keymaps
  # e.g., `my_keymap`
  KEYMAP = "kip93";

in pkgs.mkShell {
  # nativeBuildInputs = (with pkgs; [
  #     cacert git openssh keymapviz
  # ]) ++ (with pkgs.python3Packages; [
  #     bandit black flake8 flake8-blind-except flake8-length isort python toml
  # ]);
  nativeBuildInputs = with pkgs; [
      cacert git nix openssh
  ];

  shellHook = ''
    # Bash configs #################################################################
    shopt -s histappend
    shopt -s checkwinsize
    shopt -s globstar

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000

    # Extra bling for some commands ################################################
    eval "$(SHELL='${pkgs.bashInteractive}/bin/bash' '${pkgs.lesspipe}/bin/lesspipe.sh')"
    eval "$('${pkgs.coreutils}/bin/dircolors' -b)"

    # Globals ######################################################################
    _ROOT_DIR="$('${pkgs.coreutils}/bin/pwd' -P)"

    # Create a dynamic CLI prompt ##################################################
    _compute_prompt() {
      # First of all, get the exit code of the command before it is lost.
      local XC=$?
      local XC_colour="$(if [ $XC -eq 0 ] ; then '${pkgs.coreutils}/bin/printf' 10 ; elif [ $XC -lt 128 ] ; then '${pkgs.coreutils}/bin/printf' 9 ; else '${pkgs.coreutils}/bin/printf' 11 ; fi)"
      local XC_PS1="\[\033[38;5;''${XC_colour}m\]$('${pkgs.coreutils}/bin/printf' '0x%02X' $XC)\[\033[1m\]\[$('${pkgs.ncurses}/bin/tput' sgr0)\]"

      # Compute the path relative to the root of the project (or absolute path if outside of said folder).
      local path="$('${pkgs.coreutils}/bin/realpath' -m --relative-to="$_ROOT_DIR" "$('${pkgs.coreutils}/bin/pwd')")/"
      [[ "$path" =~ ^\.\..+$ ]] && path="$('${pkgs.coreutils}/bin/pwd')"
      [[ "$path" =~ ^/.+$|^\./$ ]] || path="./$path"
      local path_PS1="\[\033[1;38;5;12m\]$path\[$('${pkgs.ncurses}/bin/tput' sgr0)\]"

      # Check the branch of the repo and its status.
      local git_status="$('${pkgs.git}/bin/git' -C "$_ROOT_DIR" status --porcelain)"
      local ref="$('${pkgs.git}/bin/git' -C "$_ROOT_DIR" rev-parse --abbrev-ref HEAD)"
      [ "$ref" = "HEAD" ] && ref="$('${pkgs.git}/bin/git' -C "$_ROOT_DIR" rev-parse --short HEAD)"
      local ref_colour="$(if [ "$('${pkgs.coreutils}/bin/printf' '%s' "$git_status" | wc -l)" -eq 0 ] ; then '${pkgs.coreutils}/bin/printf' 10 ; elif '${pkgs.coreutils}/bin/printf' '%s' "$git_status" | '${pkgs.gnugrep}/bin/grep' -q '^.\S' ; then '${pkgs.coreutils}/bin/printf' 9 ; else '${pkgs.coreutils}/bin/printf' 11 ; fi)"
      local ref_PS1="\[\033[1;38;5;''${ref_colour}m\]$ref\[$('${pkgs.ncurses}/bin/tput' sgr0)\]"

      # Nix shell hint.
      local nix_PS1='\[\033[1;38;5;13m\]nix\[$('${pkgs.ncurses}/bin/tput' sgr0)\]'

      # Colour CLI prompt.
      # e.g., [ nix @ master : ./ ] 0x00 >
      #   nix    :  Just a hardcoded value to hint that we are inside the nix-shell environment.
      #   master :  Current git branch, coloured according to the status of the repo.
      #   ./     :  The current path, as computed above. In this case, it is the project root itself.
      #   0x00   :  The exit code of the last command. 0x00 means success (and will be coloured green), 0x01-0x7F
      #             means that there is an error (and is coloured red), and 0xF0-0xFF are signals (so coloured
      #             yellow).
      PS1="\[$('${pkgs.ncurses}/bin/tput' sgr0)\][ $nix_PS1 @ $ref_PS1 : $path_PS1 ] $XC_PS1 > \[$('${pkgs.ncurses}/bin/tput' sgr0)\]"

      return $XC  # Restore the original exit code
    }
    PROMPT_COMMAND=_compute_prompt

    # Aliases ######################################################################
    alias ls="'${pkgs.coreutils}/bin/ls' --color=auto"
    alias ll="'${pkgs.coreutils}/bin/ls' --color=auto -lAh"

    setup() {
      local XC=0

      [ -d "$_ROOT_DIR/QMK" ] && '${pkgs.coreutils}/bin/printf' '# Clean up submodule ------------------------------------------------------------------------------------------------- #\n'
      [ -d "$_ROOT_DIR/QMK" ] && (
        '${pkgs.coreutils}/bin/rm' -rf "$_ROOT_DIR/QMK/" && '${pkgs.coreutils}/bin/printf' "Submodule path 'QMK': deleted\n" || XC=$(( $XC + 1 )) ; '${pkgs.coreutils}/bin/printf' '\n'
      )

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# Init submodule ----------------------------------------------------------------------------------------------------- #\n'
      [ $XC -ne 0 ] || (
        '${pkgs.git}/bin/git' -C "$_ROOT_DIR" submodule update --init --recursive --progress
      ) || XC=$(( $XC + 2 )) ; [ $(( $XC & 0xFD )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# Set up udev rules -------------------------------------------------------------------------------------------------- #\n'
      [ $XC -ne 0 ] || (
        '${pkgs.coreutils}/bin/printf' 'Set up /etc/udev/rules.d/\n' && \
          su -c "'${pkgs.coreutils}/bin/mkdir' -p '/etc/udev/rules.d/' && '${pkgs.coreutils}/bin/cp' -rf \"$_ROOT_DIR/QMK/util/udev/\"* '/etc/udev/rules.d/'" && \
          '${pkgs.coreutils}/bin/printf' '/etc/udev/rules.d/ set up successfully\n'
      ) || XC=$(( $XC + 4 )) ; [ $(( $XC & 0xFB )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      return $XC
    }

    lint() {
      local XC=0

      '${pkgs.coreutils}/bin/printf' '# Link keymap -------------------------------------------------------------------------------------------------------- #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/ln' -sf "$_ROOT_DIR" "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 1 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# QMK linting -------------------------------------------------------------------------------------------------------- #\n'
      [ $XC -ne 0 ] || (
        cd "$_ROOT_DIR/QMK" && '${pkgs.nix}/bin/nix-shell' --pure --run "qmk lint -kb '${KEYBOARD}' -km '${KEYMAP}'"
      ) || XC=$(( $XC + 2 )) ; [ $(( $XC & 0xFD )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      '${pkgs.coreutils}/bin/printf' '# Unlink keymap ------------------------------------------------------------------------------------------------------ #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Unliked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 4 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      return $XC
    }

    compile() {
      local XC=0

      '${pkgs.coreutils}/bin/printf' '# Clean up old builds ------------------------------------------------------------------------------------------------ #\n'
      (cd "$_ROOT_DIR/QMK" && '${pkgs.nix}/bin/nix-shell' --pure --run 'qmk clean') && \
        '${pkgs.coreutils}/bin/printf' 'Cleaned QMK/.build\n' || XC=$(( $XC + 1 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      '${pkgs.coreutils}/bin/printf' '# Link keymap -------------------------------------------------------------------------------------------------------- #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/ln' -sf "$_ROOT_DIR" "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 2 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# Compile ------------------------------------------------------------------------------------------------------------ #\n'
      [ $XC -ne 0 ] || (
        cd "$_ROOT_DIR/QMK" && '${pkgs.nix}/bin/nix-shell' --pure --run "qmk compile -j 16 -kb '${KEYBOARD}' -km '${KEYMAP}'"
      ) || XC=$(( $XC + 4 )) ; [ $(( $XC & 0xFB )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# Extract HEX file --------------------------------------------------------------------------------------------------- #\n'
      [ $XC -ne 0 ] || (
      '${pkgs.coreutils}/bin/ls' "$_ROOT_DIR/QMK/.build"/*.hex | head -1 | xargs -i mv -f {} "$_ROOT_DIR/firmware.hex" && \
          '${pkgs.coreutils}/bin/printf' 'Extracted firmware.hex\n'
      ) || XC=$(( $XC + 8 )) ; [ $(( $XC & 0xF7 )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      '${pkgs.coreutils}/bin/printf' '# Unlink keymap ------------------------------------------------------------------------------------------------------ #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Unliked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 16 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      return $XC
    }

    flash() {  # TODO: This is not detecting the keyboard
      local XC=0

      '${pkgs.coreutils}/bin/printf' '# Link keymap -------------------------------------------------------------------------------------------------------- #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/ln' -sf "$_ROOT_DIR" "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 1 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      [ $XC -ne 0 ] || '${pkgs.coreutils}/bin/printf' '# Flash keyboard ----------------------------------------------------------------------------------------------------- #\n'
      [ $XC -ne 0 ] || (
        cd "$_ROOT_DIR/QMK" && '${pkgs.nix}/bin/nix-shell' --pure --run "qmk flash -kb '${KEYBOARD}' -km '${KEYMAP}'"
      ) || XC=$(( $XC + 2 )) ; [ $(( $XC & 0xFD )) -eq 0 ] && '${pkgs.coreutils}/bin/printf' '\n'

      '${pkgs.coreutils}/bin/printf' '# Unlink keymap ------------------------------------------------------------------------------------------------------ #\n'
      '${pkgs.coreutils}/bin/rm' -f "$_ROOT_DIR"/'QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}' && \
        '${pkgs.coreutils}/bin/printf' 'Unliked QMK/keyboards/${KEYBOARD}/keymaps/${KEYMAP}\n' || XC=$(( $XC + 4 )) ; '${pkgs.coreutils}/bin/printf' '\n'

      return $XC
    }

    help() {  # TODO: First finish other commands before fully documenting them
      return 0
    }
  '';
}

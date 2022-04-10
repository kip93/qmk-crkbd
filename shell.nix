#################################################################################################################
# Portable bash shell with all dependencies and scripts to work with QMK.                                       #
#                                                                                                               #
# Copyright 2022  Leandro Emmanuel Reina Kiperman <@kip93>                                                      #
#                                                                                                               #
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General    #
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your     #
# option) any later version.                                                                                    #
#                                                                                                               #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the    #
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License   #
# for more details.                                                                                             #
#                                                                                                               #
# You should have received a copy of the GNU General Public License along with this program. If not, see        #
# <http://www.gnu.org/licenses/>.                                                                               #
#################################################################################################################

{ pkgs ? import <nixpkgs> { }, ... }:
let
  #################
  # Configuration #
  #################

  # Name of the folder inside the QMK submodule
  # e.g., `ergodox_ez`, `0xcb/1337`, et cetera
  KEYBOARD = "crkbd";

  # Number of threads to be used when compiling.
  PARALLEL = 16;

in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cacert
    git
    nix
    openssh
  ];

  shellHook = with pkgs; ''
    # Bash configs #################################################################
    shopt -s histappend
    shopt -s cmdhist
    shopt -s checkwinsize
    shopt -s globstar
    shopt -s dotglob

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000

    # Extra bling for some commands ################################################
    eval "$(SHELL='${bashInteractive}/bin/bash' '${lesspipe}/bin/lesspipe.sh')"
    eval "$('${coreutils}/bin/dircolors' -b)"

    # Globals ######################################################################
    _ROOT_DIR="$('${coreutils}/bin/pwd' -P)"

    # Create a dynamic CLI prompt ##################################################
    _compute_prompt() {
      # First of all, get the exit code of the command before it is lost.
      local XC=$?
      local XC_colour="$(
        if [ "''${XC}" -eq 0 ] ; then
          '${coreutils}/bin/printf' 10 ;
        elif [ "''${XC}" -lt 128 ] ; then
          '${coreutils}/bin/printf' 9  ;
        else
          '${coreutils}/bin/printf' 11 ;
        fi ;
      )"
      local XC_PS1="\[\033[38;5;''${XC_colour}m\]$('${coreutils}/bin/printf' '0x%02X' "''${XC}")\[\033[1m\]\[$('${ncurses}/bin/tput' sgr0)\]"

      # Compute the path relative to the root of the project (or absolute path if outside of said folder).
      local path="$(
        '${coreutils}/bin/realpath' -m --relative-to="''${_ROOT_DIR}" "$('${coreutils}/bin/pwd')"
      )/"
      [[ "''${path}" =~ ^\.\..+$    ]] && path="$('${coreutils}/bin/pwd')"
      [[ "''${path}" =~ ^/.+$|^\./$ ]] || path="./''${path}"
      local path_PS1="\[\033[1;38;5;12m\]''${path}\[$('${ncurses}/bin/tput' sgr0)\]"

      # Check the branch of the repo and its status.
      local is_git="$(
        '${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --git-dir >/dev/null 2>&1 &&
          [ "$('${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --show-toplevel)" -ef "''${_ROOT_DIR}" ] &&
          '${coreutils}/bin/printf' true ;
      )"
      local git_status="$(
        [ ! -z "''${is_git}" ] &&
          '${git}/bin/git' -C "''${_ROOT_DIR}" status --porcelain ;
      )"
      local ref="$(
        if [ ! -z "''${is_git}" ] ; then
          '${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --abbrev-ref HEAD 2>/dev/null || true ;
        else
          '${coreutils}/bin/printf' '<N/A>' ;
        fi ;
      )"
      [ "''${ref}" = "HEAD" ] && ref="$(
        '${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --short HEAD 2>/dev/null ||
          '${git}/bin/git' -C "''${_ROOT_DIR}" branch --show-current ;
      )"
      local ref_colour="$(
        if [ -z "''${is_git}" ] ; then
          '${coreutils}/bin/printf' 9  ;
        elif [ \
          "$(
            '${coreutils}/bin/printf' '%s\n' "''${git_status}" |
              '${gnused}/bin/sed' '/^\s*$/d' |
              '${coreutils}/bin/wc' -l ;
          )" -eq 0 \
        ] ; then
          '${coreutils}/bin/printf' 10 ;
        elif
          '${coreutils}/bin/printf' '%s\n' "''${git_status}" |
            '${gnugrep}/bin/grep' -q '^.\S' ; then
          '${coreutils}/bin/printf' 9  ;
        else
          '${coreutils}/bin/printf' 11 ;
        fi ;
      )"
      local ref_PS1="\[\033[1;38;5;''${ref_colour}m\]$ref\[$('${ncurses}/bin/tput' sgr0)\]"

      # Nix shell hint.
      local nix_PS1='\[\033[1;38;5;13m\]NIX+QMK\[$('${ncurses}/bin/tput' sgr0)\]'

      # Colour CLI prompt.
      PS1="\[$('${ncurses}/bin/tput' sgr0)\][ ''${nix_PS1} @ ''${ref_PS1} : ''${path_PS1} ] ''${XC_PS1} > \[$('${ncurses}/bin/tput' sgr0)\]"

      return "''${XC}"  # Restore the original exit code
    }
    PROMPT_COMMAND=_compute_prompt

    # Aliases ######################################################################
    alias ls="'${coreutils}/bin/ls' --color=auto"
    alias ll="'${coreutils}/bin/ls' --color=auto -lAh"

    # Commands #####################################################################
    init() {
      local XC=0

      (
        '${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --git-dir >/dev/null 2>&1 && \
        [ "$('${git}/bin/git' -C "''${_ROOT_DIR}" rev-parse --show-toplevel)" -ef "''${_ROOT_DIR}" ] ;
      ) || (
        '${coreutils}/bin/printf' \
          '# \033[3mInitialise repo\033[0m ------------------------------------------------------------------------------------- #\n' ;
        (
          '${git}/bin/git' -C "''${_ROOT_DIR}" init -b main
        ) || XC="$(( "''${XC}" + 0x01 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      )

      [ -d "''${_ROOT_DIR}/QMK/" ] && (
        '${coreutils}/bin/printf' \
          '# \033[3mClean up submodule\033[0m ---------------------------------------------------------------------------------- #\n' ;
        (
          '${coreutils}/bin/rm' -rf -- "''${_ROOT_DIR}/QMK/" &&
            '${coreutils}/bin/printf' "Submodule path 'QMK': deleted\n" ;
        ) || XC="$(( "''${XC}" + 0x02 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      )

      (
        '${git}/bin/git' -C "''${_ROOT_DIR}" config --file .gitmodules --get-regexp path |
          '${gawk}/bin/awk' '{ print $2 }' |
          '${gnugrep}/bin/grep' -q '^QMK$' ;
      ) || (
        '${coreutils}/bin/printf' \
          '# \033[3mAdd QMK submodule\033[0m ----------------------------------------------------------------------------------- #\n' ;
        (
          '${git}/bin/git' -C "''${_ROOT_DIR}" submodule add --branch master -- 'https://github.com/qmk/qmk_firmware/' QMK ;
        ) || XC="$(( "''${XC}" + 0x04 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      )

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mInit submodule\033[0m -------------------------------------------------------------------------------------- #\n' ;
        (
          '${git}/bin/git' -C "''${_ROOT_DIR}" submodule update --init --recursive --progress ;
        ) || XC="$(( "''${XC}" + 0x08 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      '${coreutils}/bin/printf' \
        '# \033[3mClean up workspace\033[0m ---------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/rm' -rf -- "''${_ROOT_DIR}/keymap/" ;
      ) || XC="$(( "''${XC}" + 0x10 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      '${coreutils}/bin/printf' \
        '# \033[3mCopy default keymap\033[0m --------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/cp' -rf -- "''${_ROOT_DIR}/QMK/keyboards/${KEYBOARD}/keymaps/default" "''${_ROOT_DIR}/keymap" ;
      ) || XC="$(( "''${XC}" + 0x20 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    setup() {
      local XC=0

      '${coreutils}/bin/printf' \
        '# \033[3mSet up udev rules\033[0m ----------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/printf' 'Set up /etc/udev/rules.d/\n' &&
          $(
            (${which}/bin/which doas >/dev/null 2>/dev/null && ${coreutils}/bin/printf 'doas bash') ||
              (${which}/bin/which sudo >/dev/null 2>/dev/null && ${coreutils}/bin/printf 'sudo bash') ||
              (${coreutils}/bin/printf 'su')
          ) -c "
            '${coreutils}/bin/mkdir' -p '/etc/udev/rules.d/' &&
            '${coreutils}/bin/cp' -rf \"''${_ROOT_DIR}/QMK/util/udev/\"* '/etc/udev/rules.d/'
          " &&
          '${coreutils}/bin/printf' '/etc/udev/rules.d/ set up successfully\n' ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      '${coreutils}/bin/printf' \
        '# \033[3mResize /run/user/$UID\033[0m ------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/printf' 'Set up /etc/udev/rules.d/\n' &&
          $(
            (${which}/bin/which doas >/dev/null 2>/dev/null && ${coreutils}/bin/printf 'doas sh') ||
              (${which}/bin/which sudo >/dev/null 2>/dev/null && ${coreutils}/bin/printf 'sudo sh') ||
              (${coreutils}/bin/printf 'su')
          ) -c "
            '${coreutils}/bin/mkdir' -p '/etc/systemd/logind.conf.d/' &&
            '${coreutils}/bin/printf' '[Login]\nRuntimeDirectorySize=99%%\n' >'/etc/systemd/logind.conf.d/runtime_directory_size.conf'
          " &&
          '${coreutils}/bin/printf' '/run/user/$UID resized successfully\n' ;
      ) || XC="$(( "''${XC}" + 0x02 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mFinish\033[0m ---------------------------------------------------------------------------------------------- #\n' ;
        '${coreutils}/bin/printf' '\033[3mSet up complete.\nPlease reboot your system to ensure that changes take effect.\033[0m\n\n'
      fi

      return "''${XC}"
    }

    update() {
      local XC=0

      '${coreutils}/bin/printf' \
        '# \033[3mUpdate submodules\033[0m ----------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}" submodule update --remote --progress ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    clean() {
      local XC=0

      '${coreutils}/bin/printf' \
        '# \033[3mClean workspace\033[0m ------------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}/QMK" clean -df &&
          '${git}/bin/git' -C "''${_ROOT_DIR}" clean -dfX ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    lint() {
      local XC=0

      local KEYMAP_ID="$('${coreutils}/bin/cat' /proc/sys/kernel/random/uuid)"

      '${coreutils}/bin/printf' \
        '# \033[3mLink keymap\033[0m ----------------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/rm' -f -- "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/ln' -sf "''${_ROOT_DIR}/keymap" "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/%s\n' "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mQMK linting\033[0m ----------------------------------------------------------------------------------------- #\n' ;
        (
          cd "''${_ROOT_DIR}/QMK" &&
            '${nix}/bin/nix-shell' --pure --run "qmk lint --strict -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x02 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      '${coreutils}/bin/printf' \
        '# \033[3mUnlink keymap\033[0m --------------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}/QMK" clean -df ;
      ) || XC="$(( "''${XC}" + 0x04 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    format() {
      local XC=0

      local KEYMAP_ID="$('${coreutils}/bin/cat' /proc/sys/kernel/random/uuid)"

      '${coreutils}/bin/printf' \
        '# \033[3mLink keymap\033[0m ----------------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/rm' -f -- "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/ln' -sf "''${_ROOT_DIR}/keymap" "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/%s\n' "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mFormat code\033[0m ----------------------------------------------------------------------------------------- #\n' ;
        (
          cd "''${_ROOT_DIR}/QMK" &&
            '${nix}/bin/nix-shell' --pure --run "${clang-tools}/bin/clang-format -i --verbose \$(
              ${findutils}/bin/find -L 'keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" -type f -regextype awk -regex '.+\.(h|hpp|c|cpp|inc)'
            )" ;
        ) || XC="$(( "''${XC}" + 0x02 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      '${coreutils}/bin/printf' \
        '# \033[3mUnlink keymap\033[0m --------------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}/QMK" clean -df ;
      ) || XC="$(( "''${XC}" + 0x04 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    compile() {
      local XC=0

      local KEYMAP_ID="$('${coreutils}/bin/cat' /proc/sys/kernel/random/uuid)"

      '${coreutils}/bin/printf' \
        '# \033[3mClean up old builds\033[0m --------------------------------------------------------------------------------- #\n' ;
      (
        cd "''${_ROOT_DIR}/QMK" &&
          '${nix}/bin/nix-shell' --pure --run 'qmk clean' &&
          '${coreutils}/bin/printf' 'Cleaned QMK/.build\n' ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      '${coreutils}/bin/printf' \
        '# \033[3mLink keymap\033[0m ----------------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/rm' -f -- "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/ln' -sf "''${_ROOT_DIR}/keymap" "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/%s\n' "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mCompile\033[0m --------------------------------------------------------------------------------------------- #\n' ;
        (
          cd "''${_ROOT_DIR}/QMK" &&
            '${nix}/bin/nix-shell' --pure --run "qmk compile -j '${builtins.toString PARALLEL}' -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x04 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mExtract HEX file\033[0m ------------------------------------------------------------------------------------ #\n' ;
        (
          '${coreutils}/bin/mkdir' -p "''${_ROOT_DIR}/.build" &&
            '${coreutils}/bin/ls' "''${_ROOT_DIR}/QMK/.build"/*.hex |
              '${coreutils}/bin/head' -1 |
              '${findutils}/bin/xargs' -i cp -f -- '{}' "''${_ROOT_DIR}/.build/firmware.hex" &&
            '${coreutils}/bin/printf' 'Extracted .build/firmware.hex\n' ;
        ) || XC="$(( "''${XC}" + 0x08 ))" ;
        '${coreutils}/bin/printf' '\n'
      fi

      '${coreutils}/bin/printf' \
        '# \033[3mUnlink keymap\033[0m --------------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}/QMK" clean -df ;
      ) || XC="$(( "''${XC}" + 0x10 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    flash() {
      local XC=0

      local KEYMAP_ID="$('${coreutils}/bin/cat' /proc/sys/kernel/random/uuid)"

      '${coreutils}/bin/printf' \
        '# \033[3mClean up old builds\033[0m --------------------------------------------------------------------------------- #\n' ;
      (
        cd "''${_ROOT_DIR}/QMK" &&
          '${nix}/bin/nix-shell' --pure --run 'qmk clean' &&
          '${coreutils}/bin/printf' 'Cleaned QMK/.build\n' ;
      ) || XC="$(( "''${XC}" + 0x01 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      '${coreutils}/bin/printf' \
        '# \033[3mLink keymap\033[0m ----------------------------------------------------------------------------------------- #\n' ;
      (
        '${coreutils}/bin/rm' -f -- "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/ln' -sf "''${_ROOT_DIR}/keymap" "''${_ROOT_DIR}"/'QMK/keyboards/${KEYBOARD}/keymaps'/"''${KEYMAP_ID}" &&
          '${coreutils}/bin/printf' 'Linked QMK/keyboards/${KEYBOARD}/keymaps/%s\n' "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mCompile\033[0m --------------------------------------------------------------------------------------------- #\n' ;
        (
          cd "''${_ROOT_DIR}/QMK" &&
            '${nix}/bin/nix-shell' --pure --run "qmk compile -j '${builtins.toString PARALLEL}' -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x04 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      if [ "''${XC}" -eq 0 ] ; then
        '${coreutils}/bin/printf' \
          '# \033[3mFlash\033[0m ----------------------------------------------------------------------------------------------- #\n' ;
        (
          cd "''${_ROOT_DIR}/QMK" &&
            '${nix}/bin/nix-shell' --pure --run "qmk flash -j '${builtins.toString PARALLEL}' -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x08 ))" ;
        '${coreutils}/bin/printf' '\n' ;
      fi

      '${coreutils}/bin/printf' \
        '# \033[3mUnlink keymap\033[0m --------------------------------------------------------------------------------------- #\n' ;
      (
        '${git}/bin/git' -C "''${_ROOT_DIR}/QMK" clean -df ;
      ) || XC="$(( "''${XC}" + 0x10 ))" ;
      '${coreutils}/bin/printf' '\n' ;

      return "''${XC}"
    }

    help() {
      '${coreutils}/bin/cat' <<EOF | MANPAGER="''${MANPAGER:-''${PAGER:-${most}/bin/most -s}}" '${man}/bin/man' -l - 2>/dev/null
    .TH "NIX+QMK" "1" "" "" "Nix+QMK toolbox"
    .\----------------------------------------------------------------------------\.
    .SH NAME
    .IP clean .9i
    - Clean workdir.
    .IP compile
    - Build the keymap into a flashable .hex file.
    .IP flash
    - Burn the firmware onto a keyboard.
    .IP format
    - Formats the keymap code.
    .IP help
    - Show help info on available commands.
    .IP init
    - Setup your workspace.
    .IP lint
    - Run a simple lint on the keymap source code.
    .IP setup
    - Configure the work environment.
    .IP update
    - Update QMK to latest version.
    .IP welcome
    - Show the welcome screen.
    .\----------------------------------------------------------------------------\.
    .SH DESCRIPTION
    Set of scripts to handle out of tree QMK keymaps. The intended purpose of these
    is to both decluter QMK itself and to allow versioning of QMK to mitigate the
    effects of breaking changes.
    .PP
    NOTE: None of these commands take any arguments.
    .\----------------------------------------------------------------------------\.
    .SH EXAMPLES
    Usual development goes something along the lines:
    .PP
    .nf
    .RS
    # Install Nix
    sh <(curl -L 'https://nixos.org/nix/install') --no-daemon
    # Clone keymap repo
    # If you don't clone, an empty repo will be initialised later on
    git clone 'https://github.com/<USER>/<REPO>/' '<WORKDIR>'
    cd '<WORKDIR>'
    # Enter Nix+QMK toolbox
    nix-shell
    # Initialise your workspace, including a default keymap
    init
    # Set up environment
    setup
    # Reboot to make environment setup changes take effect
    sudo reboot now

    # After reboot, move back to workdir
    cd '<WORKDIR>'
    # Enter back into Nix+QMK toolbox
    nix-shell
    # Edit the keymap
    vim ./keymap/keymap.c
    # Format code
    format
    # Check code
    lint
    # Once done editing, compile the code
    compile
    # After the code compiled successfully, flash it
    # (Put the keyboard into bootloader mode when prompted)
    flash
    # Clean up build files
    clean

    # When there is an update to QMK
    update
    # You may need to set up the environment again
    setup
    # Reboot to make setup changes take effect
    sudo reboot now
    .RE
    .fi
    .\----------------------------------------------------------------------------\.
    .SH PROMPT EXPLAINED
    The CLI tool has a custom prompt, which shows some non essential but nice to
    have info.
    .PP
    .nf

        +-------------------------- A simple hardcoded value, to serve as a
        |                           hint that we are currently inside the
        |                           toolbox environment.
        |
        |       +------------------ The current ref of the repo. May be a
        |       |                   branch name, a commit hash, or <N/A>,
        |       |                   depending of the current status of the
        |       |                   repo (or lack thereof). It also sports
        |       |                   a colour code:
        |       |                     * Green for clean repos.
        |       |                     * Yellow for a repo with staged but
        |       |                       uncommitted changes.
        |       |                     * Red if there are unstaged changes.
        |       |
        |       |       +---------- The current directory, relative to the
        |       |       |           root of the project.
        |       |       |
        |       |       |       +-- The exit code of the last command,
        |       |       |       |   formatted in HEX and colour coded.
        |       |       |       |     * Green for success (0x00).
        |       |       |       |     * Red for errors (0x01-0x7F).
        |       |       |       |     * Yellow for signals (0x80-0xFF).
        V       V       V       V
    [ NIX+QMK @ main : ./foo/ ] 0x00 >

    .fi
    .\----------------------------------------------------------------------------\.
    .SH TROUBLESHOOTING
    If something is not working as expected, the first step to check is the exit
    code itself. I've wrote the scripts in such a way that each bit in the exit code
    corresponds to a specific section of said script. e.g., if the code is 5, then
    the sections 1 and 3 failed ( 2^(1-1) + 2^(3-1) = 5 ).
    .PP
    From the exit code you may be able to inspect the shell.nix file to determine
    the source of the issue (the entirety of the relevant code is in there in a
    monolithic file).
    .PP
    If you want to open an issue or a PR feel free to do so @
    .br
    https://github.com/kip93/qmk-crkbd/
    EOF

      return 0
    }

    welcome() {
      '${coreutils}/bin/printf' '\033[0m     , , , , , ,\n'
      '${coreutils}/bin/printf' '\033[0m   \033[1;30m.-------------.\033[0m\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|             | \033[0m-   \033[3mWelcome to this (unofficial) \033[1mNix+QMK toolbox\033[0;3m.\033[0m\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|   \033[0;1m|  |  |\033[0;1;30m   | \033[0m-\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|   \033[0;1m|  |  |\033[0;1;30m   | \033[0m-   \033[3mAn opinionated set of scripts for standalone QMK keymaps\033[0m\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|   \033[0;1m|__|__|\033[0;1;30m   | \033[0m-\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|      \033[0;1m|\033[0;1;30m      | \033[0m-\n'
      '${coreutils}/bin/printf' '\033[0m - \033[1;30m|_____________| \033[0m-\n'
      '${coreutils}/bin/printf' '\033[0m     , , , , , ,\n'
      '${coreutils}/bin/printf' '\n'
      '${coreutils}/bin/printf' '\033[0m\033[3mType `help` to get info on available commands.\033[0m\n'
      '${coreutils}/bin/printf' '\n'

      return 0
    }

    [[ $- != *i* ]] || welcome
  '';
}

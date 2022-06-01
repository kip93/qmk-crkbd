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
  KEYBOARD = "crkbd/rev1";

in
pkgs.mkShell {
  ###############
  # Environment #
  ###############

  nativeBuildInputs = with pkgs; [
    cacert
    git
    nix
    openssh
  ];

  ###########
  # Scripts #
  ###########

  shellHook = with pkgs; ''
    # Bash configs #################################################################

    # History management
    shopt -s histappend
    shopt -s cmdhist

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000

    # Keep track of window size
    shopt -s checkwinsize

    # Globbing
    shopt -s globstar
    shopt -s dotglob

    # Extra bling for some commands ################################################

    # Add colour to less
    eval "$(SHELL=${bash}/bin/bash ${lesspipe}/bin/lesspipe.sh)"

    # Add colour to ls
    eval "$(${coreutils}/bin/dircolors -b)"

    # Functions ####################################################################

    #-------------------------------------------------------------------------------
    # Check if the system has root access.
    # Currently supported methods are sudo, doas, or su.
    #
    # Return:
    #   0 if the root user is accessible, 1 otherwise.
    #-------------------------------------------------------------------------------
    _can_root() {
      if [ "$(${which}/bin/which doas sudo su 2>/dev/null | ${coreutils}/bin/wc -l)" -gt 0 ] ; then
        return 0
      else
        return 1
      fi
    }

    #-------------------------------------------------------------------------------
    # Clean the QMK submodule.
    #-------------------------------------------------------------------------------
    _clean_qmk() {
      ${git}/bin/git -C '${toString ./QMK}' clean -df
    }

    #-------------------------------------------------------------------------------
    # Get the ref of a git repo, or <N/A> if no status is available.
    #
    # Args:
    #   $1 - The repo whose ref is fetched.
    #
    # Output:
    #   The git ref.
    #-------------------------------------------------------------------------------
    _git_ref() {
      local ref
      ref="$(
        if _is_git "''${1}" ; then
          ${git}/bin/git -C "''${1}" rev-parse --abbrev-ref HEAD 2>/dev/null || true ;
        else
          ${coreutils}/bin/printf '<N/A>' ;
        fi ;
      )"

      [ "''${ref}" = "HEAD" ] && ref="$(
        ${git}/bin/git -C "''${1}" rev-parse --short HEAD 2>/dev/null ||
        ${git}/bin/git -C "''${1}" branch --show-current ;
      )"

      ${coreutils}/bin/printf '%s\n' "''${ref}"
    }

    #-------------------------------------------------------------------------------
    # Get the status of a git repo.
    #
    # Args:
    #   $1 - The repo whose status is checked.
    #
    # Output:
    #   The status of the repo, in a parseable format.
    #-------------------------------------------------------------------------------
    _git_status() {
      _is_git "''${1}" && ${git}/bin/git -C "''${1}" status --porcelain
    }

    #-------------------------------------------------------------------------------
    # Check if a directory is a git repo.
    #
    # Args:
    #   $1 - The path to be checked.
    #
    # Return:
    #   0 if it is a git repo, non-zero otherwise.
    #-------------------------------------------------------------------------------
    _is_git() {
      ${git}/bin/git -C "''${1}" rev-parse --git-dir >/dev/null 2>&1 &&
      [ "$(${git}/bin/git -C "''${1}" rev-parse --show-toplevel)" -ef "''${1}" ]
    }

    #-------------------------------------------------------------------------------
    # Get the keymap of an otherwise clean QMK submodule.
    #
    # Output:
    #   The full path to the keymap.
    #-------------------------------------------------------------------------------
    _keymap_path() {
      printf '${toString ./QMK}/'
      _git_status '${toString ./QMK}' |
        ${coreutils}/bin/cut -d' ' -f2
    }

    #-------------------------------------------------------------------------------
    # Create a symlink of the keymap.
    #
    # Args:
    #   $1 - The name of the keymap to be created.
    #-------------------------------------------------------------------------------
    _link_keymap() {
      _qmk_exec "new-keymap -kb '${KEYBOARD}' -km ''\'''${1}'" >/dev/null 2>&1
      _keymap_path |
        ${coreutils}/bin/head -c -2 |
        ${findutils}/bin/xargs -I{} ${bash}/bin/bash -c "
          ${coreutils}/bin/rm -rf -- '{}' &&
          ${coreutils}/bin/ln -sf -- '${toString ./keymap}' '{}' ;
        " ;
    }

    #-------------------------------------------------------------------------------
    # Print a header text of fixed width.
    #
    # Args:
    #   $1 - The text of the header.
    #
    # Output:
    #   An 80 char wide header.
    #-------------------------------------------------------------------------------
    _print_header() {
      ${coreutils}/bin/printf \
        '# ---------------------------------------------------------------------------- #\r# \033[3m%s\033[0m \n' \
        "''${1}"
    }

    #-------------------------------------------------------------------------------
    # Run a command as root.
    # Currently supported methods are sudo, doas, or su.
    #
    # Args:
    #   $1 - The command to execute.
    #-------------------------------------------------------------------------------
    _root_exec() {
      if ${which}/bin/which doas >/dev/null 2>&1 ; then
        doas ${bash}/bin/bash -c "''${1}"
      elif ${which}/bin/which sudo >/dev/null 2>&1 ; then
        sudo ${bash}/bin/bash -c "''${1}"
      elif ${which}/bin/which su >/dev/null 2>&1 ; then
        su -c "''${1}"
      fi
    }

    #-------------------------------------------------------------------------------
    # Execute a QMK command.
    #
    # Args:
    #   $1 - The QMK command and its arguments.
    #-------------------------------------------------------------------------------
    _qmk_exec() {
      (
        cd '${toString ./QMK}' &&
        ${nix}/bin/nix-shell --pure --run "qmk --color ''${1}" ;
      )
    }

    #-------------------------------------------------------------------------------
    # Create a random UUID.
    #
    # Output:
    #   An UUID.
    #-------------------------------------------------------------------------------
    _uuid() {
      ${coreutils}/bin/cat /proc/sys/kernel/random/uuid
    }

    # Create a dynamic CLI prompt ##################################################

    #-------------------------------------------------------------------------------
    # Create the git status part of the PS1.
    #
    # Output:
    #   A coloured git ref, or <N/A> if no status is git repo is found.
    #-------------------------------------------------------------------------------
    _compute_git_prompt() {
      # Get the repo status
      local git_status
      git_status="$(_git_status '${toString ./.}')"

      # Get the ref, or <N/A>
      local ref
      ref="$(_git_ref '${toString ./.}')"

      # Assign a colour to the "cleaniness" of the repo
      local colour
      colour="$(
        if _is_git '${toString ./.}' ; then
          # No repo -> red
          ${coreutils}/bin/printf 9 ;
        elif [ \
          "$(
            ${coreutils}/bin/printf '%s\n' "''${git_status}" |
              ${gnused}/bin/sed '/^\s*$/d' |
              ${coreutils}/bin/wc -l ;
          )" -eq 0 \
        ] ; then
          # Clean repo -> green
          ${coreutils}/bin/printf 10 ;
        elif
          # Unstaged changes -> red
          ${coreutils}/bin/printf '%s\n' "''${git_status}" |
            ${gnugrep}/bin/grep -q '^.\S' ; then
          ${coreutils}/bin/printf 9 ;
        else
          # Staged changes -> yellow
          ${coreutils}/bin/printf 11 ;
        fi ;
      )"

      # Output
      ${coreutils}/bin/printf "\[\033[1;38;5;%sm\]%s\[$(${ncurses}/bin/tput sgr0)\]" "''${colour}" "''${ref}"
    }

    #-------------------------------------------------------------------------------
    # Create the path part of the PS1.
    #
    # Output:
    #   A coloured path string, relative to the root of the project (or absolute
    #   path if outside of said folder).
    #-------------------------------------------------------------------------------
    _compute_path_prompt() {
      # Get the current relative path
      local path
      path="$(
        ${coreutils}/bin/realpath -m --relative-to='${toString ./.}' "$(${coreutils}/bin/pwd)"
      )/"

      # If the path is outside of the root dir, use absoule path instead
      [[ "''${path}" =~ ^\.\..+$    ]] && path="$(${coreutils}/bin/pwd)"

      # Make relative paths more readable
      [[ "''${path}" =~ ^/.+$|^\./$ ]] || path="./''${path}"

      # Output
      ${coreutils}/bin/printf "\[\033[1;38;5;12m\]%s\[$(${ncurses}/bin/tput sgr0)\]" "''${path}"
    }

    #-------------------------------------------------------------------------------
    # Create the exit code part of the PS1.
    #
    # Args:
    #   $1 - Exit code.
    #
    # Output:
    #   A coloured HEX exit code.
    #-------------------------------------------------------------------------------
    _compute_xc_prompt() {
      # Assign colour depending on exit code value
      local colour
      colour="$(
        if [ "''${1}" -eq 0 ] ; then
          # Success -> green
          ${coreutils}/bin/printf 10 ;
        elif [ "''${1}" -lt 128 ] ; then
          # Error -> red
          ${coreutils}/bin/printf 9 ;
        else
          # Signal -> yellow
          ${coreutils}/bin/printf 11 ;
        fi ;
      )"

      # Output
      ${coreutils}/bin/printf "\[\033[38;5;%sm\]0x%02X\[\033[1m\]\[$(${ncurses}/bin/tput sgr0)\]" "''${colour}" "''${1}"
    }

    #-------------------------------------------------------------------------------
    # Create a dynamic PS1.
    #-------------------------------------------------------------------------------
    _compute_prompt() {
      # First of all, get the exit code of the command before it is lost.
      local XC=$?

      # Compute the different parts of the PS1
      local nix_PS1
      # shellcheck disable=SC2016
      nix_PS1='\[\033[1;38;5;13m\]NIX+QMK\[$(${ncurses}/bin/tput sgr0)\]'
      local git_PS1
      git_PS1="$(_compute_git_prompt)"
      local path_PS1
      path_PS1="$(_compute_path_prompt)"
      local XC_PS1
      XC_PS1="$(_compute_xc_prompt "''${XC}")"

      # CLI prompt.
      PS1="\[$(${ncurses}/bin/tput sgr0)\][ ''${nix_PS1} @ ''${git_PS1} : ''${path_PS1} ] ''${XC_PS1} > \[$(${ncurses}/bin/tput sgr0)\]"

      return "''${XC}"  # Restore the original exit code
    }

    PROMPT_COMMAND=_compute_prompt

    # Aliases ######################################################################

    # ls
    alias ls="${coreutils}/bin/ls --color=auto"
    alias ll="${coreutils}/bin/ls --color=auto -lAh"

    # Commands #####################################################################

    #-------------------------------------------------------------------------------
    # Initialise the current working directory.
    #-------------------------------------------------------------------------------
    init() {
      local XC=0

      local KEYMAP_ID
      KEYMAP_ID="$(_uuid)"

      if ! _is_git '${toString ./.}' ; then
        _print_header 'Initialise repo'
        (
          ${git}/bin/git -C '${toString ./.}' init -b main ;
        ) || XC="$(( "''${XC}" + 0x01 ))"
        ${coreutils}/bin/printf '\n'
      fi

      if [ -d '${toString ./QMK}' ] ; then
        _print_header 'Clean up submodule'
        (
          _clean_qmk ;
        ) || XC="$(( "''${XC}" + 0x02 ))"
        ${coreutils}/bin/printf '\n'
      fi

      if ! (
        ${git}/bin/git -C '${toString ./.}' config --file .gitmodules --get-regexp path |
          ${gawk}/bin/awk '{ print $2 }' |
          ${gnugrep}/bin/grep -q '^QMK$' ;
      ) ; then
        _print_header 'Add submodule'
        (
          ${git}/bin/git -C '${toString ./.}' submodule add --branch master -- \
            'https://github.com/qmk/qmk_firmware/' QMK ;
        ) || XC="$(( "''${XC}" + 0x04 ))"
        ${coreutils}/bin/printf '\n'
      fi

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Init submodule'
        (
          ${git}/bin/git -C '${toString ./.}' submodule update --init --recursive --progress ;
        ) || XC="$(( "''${XC}" + 0x08 ))"
        ${coreutils}/bin/printf '\n'
      fi

      _print_header 'Clean up workspace'
      (
        ${coreutils}/bin/rm -rf -- '${toString ./keymap}' ;
      ) || XC="$(( "''${XC}" + 0x10 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Init workspace'
      (
        _qmk_exec "new-keymap -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" &&
        _keymap_path |
          ${findutils}/bin/xargs -I{} ${bash}/bin/bash -c "
            ${coreutils}/bin/rm -rf -- '${toString ./keymap}' &&
            ${coreutils}/bin/cp -rf -- '{}' '${toString ./keymap}' ;
          " ;
      ) || XC="$(( "''${XC}" + 0x20 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Clean up submodule'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x40 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Set up the current machine to ensure other commands work as expected.
    # May require a reboot.
    #-------------------------------------------------------------------------------
    setup() {
      local XC=0

      if ! _can_root ; then
        ${coreutils}/bin/printf '\033[33mWARNING: No root access, skipping setup.\033[0m\n'
        return 0
      fi

      _print_header 'Set up udev rules'
      (
        _root_exec "
          ${coreutils}/bin/mkdir -p '/etc/udev/rules.d/' &&
          ${coreutils}/bin/cp -rf '${toString ./QMK/util/udev}/'* '/etc/udev/rules.d/' ;
        " && ${coreutils}/bin/printf '/etc/udev/rules.d/ set up successfully\n' ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      # shellcheck disable=SC2016
      _print_header 'Resize /run/user/$UID'
      # shellcheck disable=SC2016
      (
        _root_exec "
          ${coreutils}/bin/mkdir -p '/etc/systemd/logind.conf.d/' &&
          ${coreutils}/bin/printf '[Login]\nRuntimeDirectorySize=99%%\n' >'/etc/systemd/logind.conf.d/runtime_directory_size.conf'
        " && ${coreutils}/bin/printf '/run/user/$UID resized successfully\n' ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Finish'
        ${coreutils}/bin/printf '\033[3mSet up complete.\nPlease reboot your system to ensure that changes take effect.\033[0m\n\n'
      fi

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Update the QMK submodule.
    #-------------------------------------------------------------------------------
    update() {
      local XC=0

      _print_header 'Update submodule'
      (
        ${git}/bin/git -C '${toString ./.}' submodule update --remote -- '${toString ./QMK}' &&
        ${git}/bin/git -C '${toString ./QMK}' submodule update --force --recursive ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Clean up the working directory.
    #-------------------------------------------------------------------------------
    clean() {
      local XC=0

      _print_header 'Clean up submodule'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Clean up repo'
      (
        ${git}/bin/git -C '${toString ./.}' clean -dfX ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Lint the source code.
    #-------------------------------------------------------------------------------
    lint() {
      local XC=0

      local KEYMAP_ID
      KEYMAP_ID="$(_uuid)"

      _print_header 'Clean up submodule'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Link keymap'
      (
        _link_keymap "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Lint code'
        (
          _qmk_exec "lint --strict -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x04 ))"
        ${coreutils}/bin/printf '\n'
      fi

      _print_header 'Unlink keymap'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x08 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Format the source code.
    #-------------------------------------------------------------------------------
    format() {
      local XC=0

      local KEYMAP_ID
      KEYMAP_ID="$(_uuid)"

      _print_header 'Clean up submodule'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Link keymap'
      (
        _link_keymap "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Format code'
        (
          cd '${toString ./QMK}' &&
          ${nix}/bin/nix-shell --pure --run "
            ${findutils}/bin/find -L '$(_keymap_path)' -type f -regextype awk -regex '.+\.(h|hpp|c|cpp|inc)' |
              ${findutils}/bin/xargs ${clang-tools}/bin/clang-format -i --verbose
          " ;
        ) || XC="$(( "''${XC}" + 0x04 ))"
        ${coreutils}/bin/printf '\n'
      fi

      _print_header 'Unlink keymap'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x08 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Compile the source code.
    #-------------------------------------------------------------------------------
    compile() {
      local XC=0

      local KEYMAP_ID
      KEYMAP_ID="$(_uuid)"

      _print_header 'Clean up submodule'
      (
        _clean_qmk &&
        _qmk_exec "clean" ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Link keymap'
      (
        _link_keymap "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Compile code'
        (
          _qmk_exec "compile -j $(${coreutils}/bin/nproc --all) -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x04 ))"
        ${coreutils}/bin/printf '\n'
      fi

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Extract HEX file'
        (
          ${coreutils}/bin/mkdir -p '${toString ./.build}' &&
          ${findutils}/bin/find '${toString ./QMK/.build}' -type f -regextype awk -iregex '^.*\.(hex|bin)$' |
            ${coreutils}/bin/head -1 |
            ${findutils}/bin/xargs -I{} cp -f -- '{}' '${toString ./.build/firmware.hex}' &&
          ${coreutils}/bin/printf 'Extracted .build/firmware.hex\n' ;
        ) || XC="$(( "''${XC}" + 0x08 ))"
        ${coreutils}/bin/printf '\n'
      fi

      _print_header 'Unlink keymap'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x10 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Flash a keyboard.
    #-------------------------------------------------------------------------------
    flash() {
      local XC=0

      local KEYMAP_ID
      KEYMAP_ID="$(_uuid)"

      _print_header 'Clean up submodule'
      (
        _clean_qmk &&
        _qmk_exec "clean" ;
      ) || XC="$(( "''${XC}" + 0x01 ))"
      ${coreutils}/bin/printf '\n'

      _print_header 'Link keymap'
      (
        _link_keymap "''${KEYMAP_ID}" ;
      ) || XC="$(( "''${XC}" + 0x02 ))"
      ${coreutils}/bin/printf '\n'

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Compile code'
        (
          _qmk_exec "compile -j $(${coreutils}/bin/nproc --all) -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x04 ))"
        ${coreutils}/bin/printf '\n'
      fi

      if [ "''${XC}" -eq 0 ] ; then
        _print_header 'Flash keyboard'
        (
          _qmk_exec "flash -kb '${KEYBOARD}' -km ''\'''${KEYMAP_ID}'" ;
        ) || XC="$(( "''${XC}" + 0x08 ))"
        ${coreutils}/bin/printf '\n'
      fi

      _print_header 'Unlink keymap'
      (
        _clean_qmk ;
      ) || XC="$(( "''${XC}" + 0x10 ))"
      ${coreutils}/bin/printf '\n'

      return "''${XC}"
    }

    #-------------------------------------------------------------------------------
    # Show a man-like help page.
    #-------------------------------------------------------------------------------
    help() {
      ${coreutils}/bin/cat <<EOF | MANPAGER="''${MANPAGER:-''${PAGER:-${most}/bin/most -s}}" ${man}/bin/man -l - 2>/dev/null
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
        |                           hint that we are currently inside the QMK
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

    #-------------------------------------------------------------------------------
    # Show welcome screen.
    #-------------------------------------------------------------------------------
    welcome() {
      ${coreutils}/bin/printf '\033[0m     , , , , , ,\n'
      ${coreutils}/bin/printf '\033[0m   \033[1;30m.-------------.\033[0m\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|             | \033[0m-   \033[3mWelcome to this (unofficial) \033[1mNix+QMK toolbox\033[0;3m.\033[0m\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|   \033[0;1m|  |  |\033[0;1;30m   | \033[0m-\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|   \033[0;1m|  |  |\033[0;1;30m   | \033[0m-   \033[3mAn opinionated set of scripts for standalone QMK keymaps.\033[0m\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|   \033[0;1m|__|__|\033[0;1;30m   | \033[0m-\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|      \033[0;1m|\033[0;1;30m      | \033[0m-\n'
      ${coreutils}/bin/printf '\033[0m - \033[1;30m|_____________| \033[0m-\n'
      ${coreutils}/bin/printf '\033[0m     , , , , , ,\n'
      ${coreutils}/bin/printf '\n'
      # shellcheck disable=SC2016
      ${coreutils}/bin/printf '\033[0m\033[3mType `help` to get info on available commands.\033[0m\n'
      ${coreutils}/bin/printf '\n'

      return 0
    }

    [[ $- != *i* ]] || welcome
  '';
}

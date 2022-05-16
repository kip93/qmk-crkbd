{ pkgs ? import <nixpkgs> { } }:
with pkgs; writeScript "nix-lint" ''
  #!${bash}/bin/bash
  set -eu
  ${findutils}/bin/find '${toString ../.}' -type f -name '*.nix' -not -path '${toString ../QMK}/*' |
    ${findutils}/bin/xargs ${nix-linter}/bin/nix-linter \
      -W no-AlphabeticalArgs \
      -W no-AlphabeticalBindings \
      -W BetaReduction \
      -W DIYInherit \
      -W EmptyInherit \
      -W EmptyLet \
      -W no-EmptyVariadicParamSet \
      -W FreeLetInFunc \
      -W LetInInheritRecset \
      -W no-ListLiteralConcat \
      -W NegateAtom \
      -W SequentialLet \
      -W SetLiteralUpdate \
      -W UnfortunateArgName \
      -W no-UnneededAntiquote \
      -W UnneededRec \
      -W UnusedArg \
      -W UnusedLetBind \
      -W UpdateEmptySet \
      -q
''

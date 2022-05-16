{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cacert
    cachix
    git
    nix
    nix-linter
    nixpkgs-fmt
    openssh
    rnix-lsp
    shellcheck
  ];
}

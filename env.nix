{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cacert
    git
    nix
    nix-linter
    nixpkgs-fmt
    openssh
  ];
}

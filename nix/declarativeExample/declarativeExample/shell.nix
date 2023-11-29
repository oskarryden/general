{ pkgs ? import <nixpkgs> {} }:
let
  message = "Nix shell is ready, get to work!";
in
pkgs.mkShell {
  buildInputs = with pkgs; [ cowsay lolcat ];
  shellHook = ''
    cowsay ${message} | lolcat
  '';
}

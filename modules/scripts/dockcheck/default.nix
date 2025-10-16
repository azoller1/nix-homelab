{ pkgs ? import <nixpkgs> {} }:

let
  dockcheck = pkgs.writeShellScriptBin "dockcheck" (builtins.readFile ./script.sh);
in
with pkgs;
mkShell {
  packages = [ dockcheck ];
}
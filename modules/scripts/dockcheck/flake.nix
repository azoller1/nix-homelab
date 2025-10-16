{
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs-unstable { inherit system; };
      in
      {
        packages.dockcheck = pkgs.writeTextFile {
          name = "dockcheck";
          executable = true;
          destination = "/bin/dockcheck";
          text =
            let
              binPath = pkgs.lib.makeBinPath [
                pkgs.dockcheck
                pkgs.coreutils
              ];
            in ''
              #!${pkgs.runtimeShell}
              export PATH="${binPath}:$PATH"
            '' + builtins.readFile ./script.sh;
        };
      }
    );
}
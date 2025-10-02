{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.agenix.url = "github:ryantm/agenix";

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      nixos-facter-modules,
      agenix,
      ...
    }:

    {
      nixosConfigurations = {

        az-us-hetzner = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/hetzner/configuration.nix
          ];
        };

        main-server = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/main-server/configuration.nix
            nixos-facter-modules.nixosModules.facter
            agenix.nixosModules.default
          ];
        };
        
        node1 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node1/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];
        };

        node2 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node2/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];
        };

        node3 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node3/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];
        };

        node4 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node4/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];
        };

        node5 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node5/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];
        };
      };
    };
}

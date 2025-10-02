{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      nixos-facter-modules,
      sops-nix,
      ...
    }:

    {
      nixosConfigurations = {

        az-us-hetzner = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/hetzner/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };

        main-server = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/main-server/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };
        
        node1 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node1/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };

        node2 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node2/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };

        node3 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node3/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };

        node4 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node4/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };

        node5 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/node5/configuration.nix
            nixos-facter-modules.nixosModules.facter
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}

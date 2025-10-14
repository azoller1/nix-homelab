{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      nixos-facter-modules,
      deploy-rs,
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

          deploy.nodes.az-us-hetzner = {
              hostname = "az-us-hetzner";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.az-us-hetzner;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };

        main-server = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/main-server/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.main-server = {
              hostname = "main-server";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.main-server;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };
        
        node1 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/node1/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.node1 = {
              hostname = "node1";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node1;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };

        node2 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/node2/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.node2 = {
              hostname = "node2";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node2;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };

        node3 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/node3/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.node3 = {
              hostname = "node3";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node3;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };

        node4 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/node4/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.node4 = {
              hostname = "node4";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node4;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };

        node5 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            disko.nixosModules.disko
            ./hosts/node5/configuration.nix
            nixos-facter-modules.nixosModules.facter
          ];

          deploy.nodes.node5 = {
              hostname = "node5";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node5;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };
      };
    };
}

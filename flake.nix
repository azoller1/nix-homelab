{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  #inputs.microvm.url = "github:microvm-nix/microvm.nix";
  #inputs.microvm.inputs.nixpkgs.follows = "nixpkgs-unstable";
  #inputs.home-manager.url = "github:nix-community/home-manager";
  #inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      disko,
      nixos-facter-modules,
      deploy-rs,
      #microvm,
      #home-manager,
      ...
    }:

    {
      # nixos-anywhere (disko,facter)
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
            #microvm.nixosModules.host
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
            #home-manager.nixosModules.home-manager
            #  {
            #    home-manager.useGlobalPkgs = true;
            #    home-manager.useUserPackages = true;
            #    home-manager.users.azoller = ./hosts/node3/home.nix;
            #  }
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

      # deploy-rs
      deploy.nodes = {
      
      az-us-hetzner = {
        hostname = "hetz-us.azollerstuff.xyz";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.az-us-hetzner;
        };
      };

      main-server = {
        hostname = "main-server";
        profiles.system = {
          sshUser = "root";
          user = "root";
          magicRollback = false;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.main-server;
        };
      };
      
      node1 = {
        hostname = "node1";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node1;
        };
      };

      node2 = {
        hostname = "node2";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node2;
        };
      };

      node3 = {
        hostname = "node3";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node3;
        };
      };

      node4 = {
        hostname = "node4";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node4;
        };
      };

      node5 = {
        hostname = "node5";
        profiles.system = {
          sshUser = "root";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node5;
        };
      };

      #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
    };
}

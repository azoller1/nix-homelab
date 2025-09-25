{ config, lib, pkgs, ... }:

{
  ## Imports
  # Hardware/Disks
  # Users
  imports = [
    ./disk-config.nix
    ../../users/azoller/default.nix
  ];
  facter.reportPath = ./facter.json;

  # Root user key, all hosts
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIukVfBl4xdLkVYoBsAfsrUQ7aG5qFiObDZbK8j6UGZj azoller@pc-linux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbbugMH2sE7ym1qtLBHY9rHoSgboe/rOFmQSL9zYzVS alexz@laptop"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.supportedFilesystems = [ "zfs" ];
  #boot.zfs.forceImportRoot = false;

  # Networking  
  networking.hostName = "node5";
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";
  # Dont use built-in firewall
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  # ZFS hostid
  #networking.hostId = "79aff78c";

  # Console
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Packages 
  environment.systemPackages = with pkgs; [
    wget
    micro
    docker
    lazyjournal
    lsof
    lm_sensors
    btop
    just
    htop
  ];

  ### Programs Config
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # git
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      user = {
    	name = "Alexander Zoller";
    	email = "personal@alexanderzoller.com";
      };
    };
  };
  
  # Docker Config
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    daemon.settings = {
      ipv6 = true;
    };
  };

  ## Containers

  virtualisation.oci-containers.containers = {

    mariadb-11 = {
      image = "ghcr.io/mariadb/mariadb:11.8.3-ubi9";
      autoStart = true;
      ports = [ "3306:3306" ];
      networks = ["mariadb"];
      hostname = "mariadb-11";

      volumes = [
        "mariadb-data:/var/lib/mysql"
      ];

      environment = {
        MARIADB_ALLOW_EMPTY_ROOT_PASSWORD = "1";
      };

    };

    postgres-17 = {
      image = "docker.io/postgres:17.6-alpine";
      autoStart = true;
      ports = [ "5432:5432" ];
      networks = ["postgres"];
      hostname = "postgres-17";

      volumes = [
        "pgdata:/var/lib/postgresql"
      ];

      environment = {
        PGDATA = "/var/lib/postgresql/17/docker";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node5/.env.secret.pg17
      ];
    };

    mongo6-ys = {
      image = "quay.io/mongodb/mongodb-community-server:6.0.25-ubi9";
      autoStart = true;
      ports = [ "27017:27017" ];
      networks = ["mongo6-ys"];
      hostname = "mongo6-ys";

      volumes = [
        "mongo-ys-data:/data/db"
      ];

      environment = {
        MONGO_INITDB_ROOT_USERNAME = "ys";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node5/.env.secret.mongo-ys
      ];

      cmd = [
        "--ipv6"
      ];
    };

    valkey-traefik = {
      image = "ghcr.io/valkey-io/valkey:8.1.3-alpine";
      autoStart = true;
      ports = [ "6379:6379" ];
      networks = ["valkey-traefik"];
      hostname = "valkey-traefik";

      volumes = [
        "valkey:/data"
      ];

      environment = {
        VALKEY_EXTRA_FLAGS = "--save 60 1 --loglevel verbose";
      };
    };
  };

  ## Services

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      UseDns = true;
    };
  };

  # System Config
  system.stateVersion = "25.05";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

}

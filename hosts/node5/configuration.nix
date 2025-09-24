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
    podman
    podman-compose
    podlet
    lazyjournal
    lsof
    lm_sensors
    btop
    podman-tui
    just
    passt
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
  
  # Podman Config
  virtualisation.docker.enable = false;
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };
  virtualisation.containers.containersConf.settings = {

    network = {
      network_backend = "netavark";
      firewall_driver = "nftables";
    };
    
    #engine = {
  	  #volume_path = "/home/azoller/containers/storage/volumes";
  	#};
  	
  };

  ## Containers

  # MariaDB
  virtualisation.oci-containers.containers = {

    mariadb = {
      image = "docker.io/mariadb:11.8.2-ubi9";
      autoStart = true;
      ports = [ "3306:3306" ];
      #networks = ["mariadb"];

      volumes = [
        "mariadb-data:/var/lib/mysql"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node5/.env.secret.mariadb
      ];

    };

    postgres17 = {
      image = "docker.io/postgres:17.5-alpine";
      autoStart = true;
      ports = [ "5432:5432" ];
      #networks = ["postgres17"];

      volumes = [
        "pgdata:/var/lib/postgresql/data"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node5/.env.secret.pg17
      ];

    };

    postgres17-sparkyfit = {
      image = "docker.io/postgres:17.5-alpine";
      autoStart = true;
      ports = [ "5433:5432" ];
      #networks = ["postgres17-sparkyfit"];

      volumes = [
        "pgdata-sparkyfit:/var/lib/postgresql/data"
      ];

      environment = {
        POSTGRES_USER = "sparkyfit"; 
        POSTGRES_DB = "sparkyfit";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node5/.env.secret.pg17-sparky
      ];

    };

    mongo6-ys = {
      image = "docker.io/mongo:6.0.25-jammy";
      autoStart = true;
      ports = [ "27017:27017" ];
      #networks = ["mongo6-ys"];

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
      image = "docker.io/valkey/valkey:8.1.3-alpine";
      autoStart = true;
      ports = [ "6379:6379" ];
      #networks = ["valkey-traefik"];

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

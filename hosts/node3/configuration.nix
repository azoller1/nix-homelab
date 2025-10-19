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
  networking.hostName = "node3";
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
    age
    sops
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

    beszel-agent = {
      image = "ghcr.io/henrygd/beszel/beszel-agent:0.12.7";
      autoStart = true;
      ports = ["45876:45876"];
      networks = ["beszel"];
      hostname = "beszel-agent";

      environment = {
        LISTEN = "45876";
        HUB_URL = "https://stats.azollerstuff.xyz";
        DOCKER_HOST = "tcp://socket-proxy-beszel:2375";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHjnUWIIjbWBWrZhZUiItXjHh1A5wo+8ABvWunvCfTb";
      };

      volumes = [
        "beszel-agent_data:/var/lib/beszel-agent"
      ];

      labels = {
        "traefik.enable" = "false";
      };
    };

    socket-proxy-beszel = {
      image = "lscr.io/linuxserver/socket-proxy:3.2.4";
      autoStart = true;
      networks = ["beszel"];
      hostname = "socket-proxy-beszel";

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        CONTAINERS = "1";
        LOG_LEVEL = "info";
        TZ = "America/Chicago";
      };

      extraOptions = [
        "--tmpfs=/run"
        "--read-only"
        "--memory=64m"
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
      ];
    };

    socket-proxy-kop = {
      image = "lscr.io/linuxserver/socket-proxy:3.2.4";
      autoStart = true;
      networks = ["kop"];
      hostname = "socket-proxy-kop";

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        CONTAINERS = "1";
        LOG_LEVEL = "info";
        TZ = "America/Chicago";
      };

      extraOptions = [
        "--tmpfs=/run"
        "--read-only"
        "--memory=64m"
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
      ];
    };

    kop = {
      image = "ghcr.io/jittering/traefik-kop:0.17";
      autoStart = true;
      networks = ["kop"];
      hostname = "kop";

      environment = {
        REDIS_ADDR = "node5.lan.internal:6379";
        KOP_HOSTNAME = "node3.lan.internal";
        DOCKER_HOST = "tcp://socket-proxy-kop:2375";
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

}

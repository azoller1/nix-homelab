{ config, lib, pkgs, ... }:

{
  ## Imports
  # Hardware/Disks
  # Users
  imports = [
    ./disk-config.nix
    ../../users/azoller/default.nix
    ../../modules/containers/dozzle-agent/default.nix
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

  # Networking  
  networking.hostName = "node1";
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  # Firewall
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  #networking.firewall.allowedTCPPorts = [
    #22
  #];

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

    socket-proxy-beszel = {
      image = "lscr.io/linuxserver/socket-proxy:3.2.6";
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

    beszel-agent = {
      image = "ghcr.io/henrygd/beszel/beszel-agent:0.14.0";
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

    marknotes = {
      image = "ghcr.io/fccview/rwmarkable:1.5.0";
      autoStart = true;
      ports = [ "10006:3000" ];
      networks = ["marknotes"];
      hostname = "marknotes";

      volumes = [
        "data:/app/data:rw"
        "config:/app/config:ro"
        "cache:/app/.next/cache:rw"
      ];

      environment = {
        NODE_ENV = "production";
      };

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.marknote.loadbalancer.server.port" = "10006";
        "traefik.http.routers.marknote.rule" = "Host(`mnotes.azollerstuff.xyz`)";
        "traefik.http.routers.marknote.entrypoints" = "https";
        "traefik.http.routers.marknote.tls" = "true";
        "traefik.http.routers.marknote.tls.certresolver" = "le";
        "traefik.http.routers.marknote.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.marknote.middlewares" = "secheader@file";
      };

    };

    socket-proxy-kop = {
      image = "lscr.io/linuxserver/socket-proxy:3.2.6";
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
      image = "ghcr.io/jittering/traefik-kop:0.18.1";
      autoStart = true;
      networks = ["kop"];
      hostname = "kop";

      environment = {
        REDIS_ADDR = "node5.lan.internal:6379";
        KOP_HOSTNAME = "node1.lan.internal";
        DOCKER_HOST = "tcp://socket-proxy-kop:2375";
      };
    };

    ys-client = {
      image = "ghcr.io/yooooomi/your_spotify_client:1.14.0";
      autoStart = true;
      ports = [ "10005:3000" ];
      networks = ["ys"];
      hostname = "ys-client";

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node1/.env.secret.ys
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.ys-client.loadbalancer.server.port" = "10005";
        "traefik.http.routers.ys-client.rule" = "Host(`spotifystats.azollerstuff.xyz`)";
        "traefik.http.routers.ys-client.entrypoints" = "https";
        "traefik.http.routers.ys-client.tls" = "true";
        "traefik.http.routers.ys-client.tls.certresolver" = "le";
        "traefik.http.routers.ys-client.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.ys-client.middlewares" = "secheader@file";
      };
    };

    ys-server = {
      image = "ghcr.io/yooooomi/your_spotify_server:1.14.0";
      autoStart = true;
      ports = [ "10004:8080" ];
      networks = ["ys"];
      hostname = "ys-server";

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node1/.env.secret.ys
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.ys-server.loadbalancer.server.port" = "10004";
        "traefik.http.routers.ys-server.rule" = "Host(`ssapi.azollerstuff.xyz`)";
        "traefik.http.routers.ys-server.entrypoints" = "https";
        "traefik.http.routers.ys-server.tls" = "true";
        "traefik.http.routers.ys-server.tls.certresolver" = "le";
        "traefik.http.routers.ys-server.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.ys-server.middlewares" = "secheader@file";
      };
    };

    vw = {
      image = "ghcr.io/dani-garcia/vaultwarden:1.34.3";
      autoStart = true;
      ports = [ "10003:80" ];
      networks = ["vw"];
      hostname = "vw";

      volumes = [
        "vw_data:/data"
      ];

      environment = {
      	ROCKET_ADDRESS = "0.0.0.0";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node1/.env.secret.vw
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.vw.loadbalancer.server.port" = "10003";
        "traefik.http.routers.vw.rule" = "Host(`vault.azollerstuff.xyz`)";
        "traefik.http.routers.vw.entrypoints" = "https";
        "traefik.http.routers.vw.tls" = "true";
        "traefik.http.routers.vw.tls.certresolver" = "le";
        "traefik.http.routers.vw.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.vw.middlewares" = "secheader@file";
      };
    };

    habittrove = {
      image = "docker.io/dohsimpson/habittrove:v0.2.29";
      autoStart = true;
      ports = [ "10002:3000" ];
      networks = ["habittrove"];
      hostname = "habittrove";

      volumes = [
        "habittrove_backups:/app/backups"
        "habittrove_data:/app/data"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node1/.env.secret.habittrove
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.habittrove.loadbalancer.server.port" = "10002";
        "traefik.http.routers.habittrove.rule" = "Host(`habits.azollerstuff.xyz`)";
        "traefik.http.routers.habittrove.entrypoints" = "https";
        "traefik.http.routers.habittrove.tls" = "true";
        "traefik.http.routers.habittrove.tls.certresolver" = "le";
        "traefik.http.routers.habittrove.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.habittrove.middlewares" = "secheader@file";
      };
    };

    baikal-dav = {
      image = "docker.io/ckulka/baikal:0.10.1-nginx-php8.2";
      autoStart = true;
      ports = [ "10001:80" ];
      networks = ["baikal-dav"];
      hostname = "baikal-dav";

      volumes = [
        "baikal-dav_config:/var/www/baikal/config"
        "baikal-dav_data:/var/www/baikal/Specific"
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.baikal-dav.loadbalancer.server.port" = "10001";
        "traefik.http.routers.baikal-dav.rule" = "Host(`dav.azollerstuff.xyz`)";
        "traefik.http.routers.baikal-dav.entrypoints" = "https";
        "traefik.http.routers.baikal-dav.tls" = "true";
        "traefik.http.routers.baikal-dav.tls.certresolver" = "le";
        "traefik.http.routers.baikal-dav.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.baikal-dav.middlewares" = "secheader@file";
      };
    };

    apprise = {
      image = "ghcr.io/caronc/apprise:1.2.1";
      autoStart = true;
      ports = [ "10000:8000" ];
      networks = ["apprise"];
      hostname = "apprise";

      volumes = [
        "apprise_config:/config"
        "apprise_plugin:/plugin"
        "apprise_attach:/attach"
        "apprise_data:/config/store"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/node1/.env.secret.apprise
      ];

      labels = {
        "kop.bind.ip" = "192.168.2.5";
        "traefik.enable" = "true";
        "traefik.http.services.apprise.loadbalancer.server.port" = "10000";
        "traefik.http.routers.apprise.rule" = "Host(`apprise.azollerstuff.xyz`)";
        "traefik.http.routers.apprise.entrypoints" = "https";
        "traefik.http.routers.apprise.tls" = "true";
        "traefik.http.routers.apprise.tls.certresolver" = "le";
        "traefik.http.routers.apprise.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.apprise.middlewares" = "secheader@file";
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

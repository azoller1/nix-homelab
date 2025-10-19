{ config, lib, pkgs, ... }:

{
  ## Imports
  # Hardware/Disks
  # Users
  # Modules/Containers
  imports = [
    ./disk-config.nix
    ../../users/azoller/default.nix
    ../../modules/containers/romm/default.nix
    ../../modules/containers/necesse/default.nix
    ../../modules/containers/diun/default.nix
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
  networking.hostName = "main-server";
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
    lazyjournal
    lsof
    lm_sensors
    btop
    just
    htop
    age
    jq
    sops
    regclient
    regsync
    regctl
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

  ## Networks (systemd services oneshot) for containers
  systemd.services."docker-network-beszel" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect beszel || docker network create beszel --ipv6
    '';
  };

  systemd.services."docker-network-grafana" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect grafana || docker network create grafana --ipv6
    '';
  };

  systemd.services."docker-network-forgejo" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect forgejo || docker network create forgejo --ipv6
    '';
  };

  systemd.services."docker-network-immich" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect immich || docker network create immich --ipv6
    '';
  };

  systemd.services."docker-network-immich-traefik" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect immich-traefik || docker network create immich-traefik --ipv6
    '';
  };

  systemd.services."docker-network-lldap" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect lldap || docker network create lldap --ipv6
    '';
  };

  systemd.services."docker-network-paperless" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect paperless || docker network create paperless --ipv6
    '';
  };

  systemd.services."docker-network-paperless-traefik" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect paperless-traefik || docker network create paperless-traefik --ipv6
    '';
  };

  systemd.services."docker-network-pocket-id" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect pocket-id || docker network create pocket-id --ipv6
    '';
  };

  systemd.services."docker-network-prom" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect prom || docker network create prom --ipv6
    '';
  };

  systemd.services."docker-network-signal-api" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect signal-api || docker network create signal-api --ipv6
    '';
  };

  systemd.services."docker-network-traefik" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect traefik || docker network create traefik --ipv6
    '';
  };

  systemd.services."docker-network-viclogs" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect viclogs || docker network create viclogs --ipv6
    '';
  };

  systemd.services."docker-network-vicmetrics" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect vicmetrics || docker network create vicmetrics --ipv6
    '';
  };

  systemd.services."docker-network-romm" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect romm || docker network create romm --ipv6
    '';
    before = [ "docker-romm.service" ];
  };

  ## Containers

  virtualisation.oci-containers.containers = {

    beszel = {
      image = "ghcr.io/henrygd/beszel/beszel:0.12.7";
      autoStart = true;
      #ports = [ "8090:8090" ];
      networks = ["beszel"];
      hostname = "beszel";

      volumes = [
        "beszel_data:/beszel_data"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.beszel.loadbalancer.server.port" = "8090";
        "traefik.http.routers.beszel.rule" = "Host(`stats.azollerstuff.xyz`)";
        "traefik.http.routers.beszel.entrypoints" = "https";
        "traefik.http.routers.beszel.tls" = "true";
        "traefik.http.routers.beszel.tls.certresolver" = "le";
        "traefik.http.routers.beszel.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.beszel.middlewares" = "secheader@file";
      };
    };

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

    forgejo = {
      image = "codeberg.org/forgejo/forgejo:12.0-rootless";
      autoStart = true;
      networks = ["forgejo"];
      hostname = "forgejo";
      #user = "azoller:users";

      environment = {
        USER_UID = "1000";
        USER_GID = "100";
      };

      volumes = [
        "forgejo:/var/lib/gitea"
        "/home/azoller/nix-homelab/hosts/main-server/.env.secret.forgejoconf:/var/lib/gitea/custom/conf/app.ini"
        "/etc/timezone:/etc/timezone:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.forgejo.service" = "forgejo";
        "traefik.http.services.forgejo.loadbalancer.server.port" = "3000";
        "traefik.http.routers.forgejo.rule" = "Host(`git.azollerstuff.xyz`)";
        "traefik.http.routers.forgejo.entrypoints" = "https";
        "traefik.http.routers.forgejo.tls" = "true";
        "traefik.http.routers.forgejo.tls.certresolver" = "le";
        "traefik.http.routers.forgejo.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.forgejo.middlewares" = "secheader@file";
        "traefik.tcp.routers.forgejoSSH.service" = "forgejoSSH";
        "traefik.tcp.services.forgejoSSH.loadbalancer.server.port" = "2222";
        "traefik.tcp.routers.forgejoSSH.rule" = "HostSNI(`git.azollerstuff.xyz`)";
        "traefik.tcp.routers.forgejoSSH.entrypoints" = "https";
        "traefik.tcp.routers.forgejoSSH.tls" = "true";
        "traefik.tcp.routers.forgejoSSH.tls.certresolver" = "le";
        "traefik.tcp.routers.forgejoSSH.tls.domains[0].main" = "*.azollerstuff.xyz";
      };
    };

    grafana = {
      image = "docker.io/grafana/grafana:12.1";
      autoStart = true;
      networks = ["grafana"];
      hostname = "grafana";

      environment = {
        GF_SERVER_ROOT_URL = "https://grafana.azollerstuff.xyz";
        GF_PLUGINS_PREINSTALL = "grafana-clock-panel";
      };

      volumes = [
        "grafana_data:/var/lib/grafana"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.grafana.loadbalancer.server.port" = "3000";
        "traefik.http.routers.grafana.rule" = "Host(`grafana.azollerstuff.xyz`)";
        "traefik.http.routers.grafana.entrypoints" = "https";
        "traefik.http.routers.grafana.tls" = "true";
        "traefik.http.routers.grafana.tls.certresolver" = "le";
        "traefik.http.routers.grafana.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.grafana.middlewares" = "secheader@file";
      };
    };

    immich-server = {
      image = "ghcr.io/immich-app/immich-server:v1.142.0";
      autoStart = true;
      networks = [
        "immich"
        "immich-traefik"
      ];

      hostname = "immich-server";

      dependsOn = [
        "immich-db"
        "immich-redis"
      ];

      devices = [
        "/dev/dri:/dev/dri"
      ];

      volumes = [
        "/mnt/hdd/media/photos-uploaded:/data"
        "/mnt/hdd/media/photos:/mnt/media/main-photos:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "immich-traefik";
        "traefik.http.services.immich-server.loadbalancer.server.port" = "2283";
        "traefik.http.routers.immich-server.rule" = "Host(`photos.azollerstuff.xyz`)";
        "traefik.http.routers.immich-server.entrypoints" = "https";
        "traefik.http.routers.immich-server.tls" = "true";
        "traefik.http.routers.immich-server.tls.certresolver" = "le";
        "traefik.http.routers.immich-server.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.immich-server.middlewares" = "secheader@file";
      };
    };

    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:v1.142.0";
      autoStart = true;
      networks = ["immich"];
      hostname = "immich-machine-learning";

      volumes = [
        "immich_cache:/cache"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
      ];

      labels = {
        "traefik.enable" = "false";
      };
    };

    immich-redis = {
      image = "docker.io/valkey/valkey:8-bookworm";
      autoStart = true;
      networks = ["immich"];
      hostname = "immich-redis";

      labels = {
        "traefik.enable" = "false";
      };
    };

    immich-db = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
      autoStart = true;
      networks = ["immich"];
      hostname = "immich-db";

      volumes = [
        "immich_db:/var/lib/postgresql/data"
      ];

      environment = {
        POSTGRES_DB = "immich";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
      ];

      labels = {
        "traefik.enable" = "false";
      };
    };

    jellyfin = {
      image = "docker.io/jellyfin/jellyfin:10.10.7";
      autoStart = true;
      hostname = "jellyfin";

      volumes = [
        "/mnt/hdd/media/jelly:/media"
        "jellyfin_config:/config"
        "jellyfin_cache:/cache"
      ];

      devices = [
        "/dev/dri/card0:/dev/dri/card0"
        "/dev/dri/renderD128:/dev/dri/renderD128"
        "/dev/kfd:/dev/kfd"
      ];

      environment = {
        JELLYFIN_PublishedServerUrl = "https://jelly.azollerstuff.xyz";
      };

      extraOptions = [
        "--network=host"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.jellyfin.loadbalancer.server.url" = "http://192.168.2.2:8096";
        "traefik.http.routers.jellyfin.rule" = "Host(`jelly.azollerstuff.xyz`)";
        "traefik.http.routers.jellyfin.entrypoints" = "https";
        "traefik.http.routers.jellyfin.tls" = "true";
        "traefik.http.routers.jellyfin.tls.certresolver" = "le";
        "traefik.http.routers.jellyfin.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.jellyfin.middlewares" = "secheader@file";
      };
    };

    lldap = {
      image = "ghcr.io/lldap/lldap:v0.6.2-alpine-rootless";
      networks = ["lldap"];
      autoStart = true;
      ports = ["3890:3890"];
      hostname = "lldap";

      volumes = [
        "lldap_data:/data"
      ];

      environment = {
        UID = "1000";
        GID = "100";
        TZ = "America/Chicago";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.lldap
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.lldap.loadbalancer.server.port" = "17170";
        "traefik.http.routers.lldap.rule" = "Host(`lldap.azollerstuff.xyz`)";
        "traefik.http.routers.lldap.entrypoints" = "https";
        "traefik.http.routers.lldap.tls" = "true";
        "traefik.http.routers.lldap.tls.certresolver" = "le";
        "traefik.http.routers.lldap.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.lldap.middlewares" = "secheader@file";
      };
    };

    paperless = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.18.4";
      networks = [
        "paperless"
        "paperless-traefik"
      ];

      autoStart = true;
      hostname = "paperless";

      dependsOn = [
        "paper-valkey"
        "paper-tika"
        "paper-gotenberg"
      ];

      volumes = [
        "paperless_data:/usr/src/paperless/data"
        "paperless_media:/usr/src/paperless/media"
        "/mnt/hdd/paperless/export:/usr/src/paperless/export"
        "/mnt/hdd/paperless/consume:/usr/src/paperless/consume"
      ];

      environment = {
        PAPERLESS_REDIS = "redis://paper-valkey:6379";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paper-gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://paper-tika:9998";
      };

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.paperless
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = "paperless-traefik";
        "traefik.http.services.paperless.loadbalancer.server.port" = "8000";
        "traefik.http.routers.paperless.rule" = "Host(`papers.azollerstuff.xyz`)";
        "traefik.http.routers.paperless.entrypoints" = "https";
        "traefik.http.routers.paperless.tls" = "true";
        "traefik.http.routers.paperless.tls.certresolver" = "le";
        "traefik.http.routers.paperless.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.paperless.middlewares" = "secheader@file";
      };
    };

    paper-valkey = {
      image = "docker.io/valkey/valkey:8-bookworm";
      autoStart = true;
      networks = ["paperless"];
      hostname = "paper-valkey";

      volumes = [
        "paperless_valkey_data:/data"
      ];

      cmd = [
        "valkey-server"
        "--save 30 1"
        "--loglevel warning"
      ];

      labels = {
        "traefik.enable" = "false";
      };
    };

    paper-tika = {
      image = "docker.io/apache/tika:3.2.2.0";
      autoStart = true;
      networks = ["paperless"];
      hostname = "paper-tika";

      labels = {
        "traefik.enable" = "false";
      };
    };

    paper-gotenberg = {
      image = "docker.io/gotenberg/gotenberg:8.20.1";
      autoStart = true;
      networks = ["paperless"];
      hostname = "paper-gotenberg";

      cmd = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];

      labels = {
        "traefik.enable" = "false";
      };
    };

    pocket-id = {
      image = "ghcr.io/pocket-id/pocket-id:v1.10.0";
      networks = ["pocket-id"];
      autoStart = true;
      hostname = "pocket-id";

      volumes = [
        "pocket-id_data:/app/data"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.pocket-id
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.pocket-id.loadbalancer.server.port" = "1411";
        "traefik.http.routers.pocket-id.rule" = "Host(`auth.azollerstuff.xyz`)";
        "traefik.http.routers.pocket-id.entrypoints" = "https";
        "traefik.http.routers.pocket-id.tls" = "true";
        "traefik.http.routers.pocket-id.tls.certresolver" = "le";
        "traefik.http.routers.pocket-id.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.pocket-id.middlewares" = "secheader@file";
      };
    };

    prom = {
      image = "docker.io/prom/prometheus:v3.5.0";
      networks = ["prom"];
      autoStart = true;
      hostname = "prom";

      volumes = [
        "prom_data:/prometheus"
        "/home/azoller/nix-homelab/hosts/main-server/.env.secret.promconf:/etc/prometheus/prometheus.yml"
      ];

      cmd = [
        "--web.enable-remote-write-receiver"
        "--config.file=/etc/prometheus/prometheus.yml"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.prom.loadbalancer.server.port" = "9090";
        "traefik.http.routers.prom.rule" = "Host(`prom.azollerstuff.xyz`)";
        "traefik.http.routers.prom.entrypoints" = "https";
        "traefik.http.routers.prom.tls" = "true";
        "traefik.http.routers.prom.tls.certresolver" = "le";
        "traefik.http.routers.prom.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.prom.middlewares" = "secheader@file";
      };
    };

    viclogs = {
      image = "docker.io/victoriametrics/victoria-logs:v1.33.1";
      networks = ["viclogs"];
      autoStart = true;
      hostname = "viclogs";

      volumes = [
        "viclogs_data:/victoria-logs-data"
      ];

      cmd = [
        "-storageDataPath=victoria-logs-data"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.viclogs.loadbalancer.server.port" = "9428";
        "traefik.http.routers.viclogs.rule" = "Host(`viclogs.azollerstuff.xyz`)";
        "traefik.http.routers.viclogs.entrypoints" = "https";
        "traefik.http.routers.viclogs.tls" = "true";
        "traefik.http.routers.viclogs.tls.certresolver" = "le";
        "traefik.http.routers.viclogs.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.viclogs.middlewares" = "secheader@file";
      };
    };

    vicmetrics = {
      image = "docker.io/victoriametrics/victoria-metrics:v1.126.0";
      networks = ["vicmetrics"];
      autoStart = true;
      hostname = "vicmetrics";

      volumes = [
        "vicmetrics_data:/victoria-metrics-data"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.vicmetrics.loadbalancer.server.port" = "8428";
        "traefik.http.routers.vicmetrics.rule" = "Host(`vicmetrics.azollerstuff.xyz`)";
        "traefik.http.routers.vicmetrics.entrypoints" = "https";
        "traefik.http.routers.vicmetrics.tls" = "true";
        "traefik.http.routers.vicmetrics.tls.certresolver" = "le";
        "traefik.http.routers.vicmetrics.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.vicmetrics.middlewares" = "secheader@file";
      };
    };

    signal-api = {
      image = "docker.io/bbernhard/signal-cli-rest-api:0.94";
      networks = ["signal-api"];
      autoStart = true;
      hostname = "signal-api";

      volumes = [
        "signal-api_data:/home/.local/share/signal-cli"
      ];

      environment = {
        MODE = "json-rpc";
      };

      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.signal-api.loadbalancer.server.port" = "8080";
        "traefik.http.routers.signal-api.rule" = "Host(`signal-api.azollerstuff.xyz`)";
        "traefik.http.routers.signal-api.entrypoints" = "https";
        "traefik.http.routers.signal-api.tls" = "true";
        "traefik.http.routers.signal-api.tls.certresolver" = "le";
        "traefik.http.routers.signal-api.tls.domains[0].main" = "*.azollerstuff.xyz";
        "traefik.http.routers.signal-api.middlewares" = "secheader@file";
      };
    };

    socket-proxy-traefik = {
      image = "lscr.io/linuxserver/socket-proxy:3.2.4";
      autoStart = true;
      networks = ["traefik"];
      hostname = "socket-proxy-traefik";

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

    traefik = {
      image = "docker.io/traefik:v3.5.2";
      networks = [
        "traefik"
        "beszel"
        "lldap"
        "paperless-traefik"
        "signal-api"
        "prom"
        "grafana"
        "viclogs"
        "vicmetrics"
        "pocket-id"
        "immich-traefik"
        "forgejo"
        "romm"
        "pelican"
        "pelican-wings"
      ];

      ports = [
        "443:9443"
        "80:8080"
        "8088:8080"
      ];

      autoStart = true;
      hostname = "traefik";
      dependsOn = ["socket-proxy-traefik"];

      volumes = [
        "/home/azoller/nix-homelab/hosts/main-server/.env.secret.traefik_acme:/acme.json"
        "/home/azoller/nix-homelab/hosts/main-server/.env.secret.traefik_config:/etc/traefik/traefik.yaml"
        "/home/azoller/nix-homelab/hosts/main-server/.env.secret.traefik_dynamic:/etc/traefik/dynamic"
      ];

      environmentFiles = [
        /home/azoller/nix-homelab/hosts/main-server/.env.secret.traefik
      ];

      labels = {
        "traefik.enable" = "false";
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

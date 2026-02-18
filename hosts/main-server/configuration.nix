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
    ../../modules/containers/backrest/default.nix
    ../../modules/containers/dozzle-agent/default.nix
    ../../modules/containers/dozzle/default.nix
    ../../modules/containers/beszel/default.nix
    ../../modules/containers/forgejo/default.nix
    ../../modules/containers/pocket-id/default.nix
    ../../modules/containers/immich/default.nix
    ../../modules/containers/jellyfin/default.nix
    ../../modules/containers/lldap/default.nix
    ../../modules/containers/paperless/default.nix
    ../../modules/containers/traefik/default.nix
    ../../modules/containers/sftpgo/default.nix
    ../../modules/containers/ntfy/default.nix
    ../../modules/containers/snr/default.nix
    ../../modules/containers/rdr/default.nix
    ../../modules/containers/nzbg/default.nix
    ../../modules/containers/recycle/default.nix
    #../../modules/containers/tuwunel/default.nix
    #../../modules/containers/patchmon/default.nix
    #../../modules/containers/seafile/default.nix
    #../../modules/containers/grafana/default.nix
    #../../modules/containers/prometheus/default.nix
    #../../modules/containers/signal-api/default.nix
    #../../modules/containers/viclogs/default.nix
    #../../modules/containers/vicmetrics/default.nix
    #../../modules/containers/wud/default.nix
    #../../modules/containers/termix/default.nix
    #../../modules/containers/cup-agent/default.nix
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
  networking.networkmanager.enable = false;
  networking.useDHCP = false;
  # networking.useNetworkd = true;
  systemd.network.enable = true;

  # LAN
  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["enp4s0"];
    networkConfig = {
      Address = ["192.168.2.2/24"];
      Gateway = "192.168.2.1";
      DNS = ["192.168.2.3"];
      IPv6AcceptRA = true;
      Domains = "lan.internal";
    };

    linkConfig.RequiredForOnline = "routable";
  };
  

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
    smartmontools
    restic
    libressl
  ];

  ### Programs/Services
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

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      UseDns = true;
    };
  };

  # Garage S3
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    settings.metadata_dir = "/mnt/extra-data/garage-meta";

    settings.data_dir = [
      {
        capacity = "100G";
        path = "/mnt/extra-data/garage";
      }
    ];

    extraEnvironment = {
      GARAGE_LOG_TO_JOURNALD = "1";
      GARAGE_ALLOW_WORLD_READABLE_SECRETS = "false";
    };

    environmentFile = "/mnt/extra-data/garage.env";

    settings = {
      db_engine = "lmdb";
      replication_factor = 1;
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      metadata_auto_snapshot_interval = "6h";
      use_local_tz = true;

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.azollerstuff.xyz";
      };

      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.azollerstuff.xyz";
        index = "index.html";
      };

      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
  };

  # Restic
  services.restic.backups = {
  
    data_local = {

      user = "root";
      passwordFile = "/home/azoller/.restic-pass-local";
      backupPrepareCommand = "/home/azoller/scripts/restic_prepare.sh";
      #backupCleanupCommand = "/home/azoller/scripts/restic_clean.sh";
      checkOpts = ["--with-cache"];
      repository = "/mnt/hdd/backups/";
      initialize = true;

      extraBackupArgs = [
        "--tag local"
        "--verbose"
      ];

      pruneOpts = [
        "--keep-daily 12"
        "--keep-weekly 7"
        "--keep-monthly 4"
        "--keep-yearly 12"
        "--group-by tags"
      ];

      exclude = [
        "/home/*/.cache"
        "/home/azoller/zfsdata"
      ];
      
      paths = [
        "/home/azoller"
      ];

      timerConfig = {
        OnCalendar = "04:30";
        Persistent = true;
        #RandomizedDelaySec = "30m";
      };
      
    };
    
    data_s3 = {
      
      user = "root";
      initialize = true;
      repositoryFile = "/home/azoller/.restic-repo-s3";
      passwordFile = "/home/azoller/.restic-pass-s3";
      environmentFile = "/home/azoller/.restic-env";
      backupPrepareCommand = "/home/azoller/scripts/restic_prepare.sh";
      #backupCleanupCommand = "/home/azoller/scripts/restic_clean.sh";
      checkOpts = ["--with-cache"];
      
      paths = [
        "/home/azoller"
      ];

      extraBackupArgs = [
        "--tag s3"
        "--verbose"
      ];

      pruneOpts = [
        "--keep-daily 12"
        "--keep-weekly 7"
        "--keep-monthly 4"
        "--keep-yearly 12"
        "--group-by tags"
      ];

      exclude = [
        "/home/*/.cache"
        "/home/azoller/zfsdata"
      ];

      timerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
        #RandomizedDelaySec = "30m";
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

  ## Containers (Non-Imports)

    virtualisation.oci-containers.containers."socket-proxy-beszel" = {
      
        image = "lscr.io/linuxserver/socket-proxy:3.2.10";
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

    virtualisation.oci-containers.containers."beszel-agent" = {

        image = "ghcr.io/henrygd/beszel/beszel-agent:0.18.3-alpine";
        autoStart = true;
        ports = ["45876:45876"];
        networks = ["beszel"];
        hostname = "beszel-agent";

        environment = {
            LISTEN = "45876";
            HUB_URL = "https://stats.zollerlab.com";
            DOCKER_HOST = "tcp://socket-proxy-beszel:2375";
            KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHjnUWIIjbWBWrZhZUiItXjHh1A5wo+8ABvWunvCfTb";
        };

        capabilities = {
            SYS_RAWIO = true;
            SYS_ADMIN = true;
        };

        devices = [
            "/dev/sda:/dev/sda"
            "/dev/sdb:/dev/sdb"
            "/dev/sdc:/dev/sdc"
            "/dev/sdd:/dev/sdd"
            "/dev/nvme0:/dev/nvme0"
        ];

        volumes = [
            "beszel-agent_data:/var/lib/beszel-agent"
        ];

        labels = {
            "traefik.enable" = "false";
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

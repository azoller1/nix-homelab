{ config, lib, pkgs, ... }:

{
  ## Imports
  # Hardware/Disks
  # Users
  imports = [
    ./disk-config.nix
    ../../users/azoller/default.nix
    ./hardware.nix
  ];

  # Root user key, all hosts
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIukVfBl4xdLkVYoBsAfsrUQ7aG5qFiObDZbK8j6UGZj azoller@pc-linux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbbugMH2sE7ym1qtLBHY9rHoSgboe/rOFmQSL9zYzVS alexz@laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdD8uhvY1tggw+U5zOf831nn43Z81atlFh+zuprFtZd azoller@main-server"
  ];

  # Bootloader, need grub for hetzner
  # boot.loader.grub.enable = true;

  # Networking
  networking.hostName = "az-vps-racknerd";
  # networking.wireless.enable = true;
  networking.networkmanager = {
    enable = true;
    settings = {
      main = {
        dns = "none";
        rc-manager = "unmanaged";
      };
    };
  };

  time.timeZone = "America/New_York";

  # Firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.firewall.allowedUDPPorts = [443];
  networking.firewall.allowedTCPPorts = [22 443];

  # Console
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    nftables
    wget
    micro
    lazyjournal
    lsof
    lm_sensors
    btop
    just
    htop
    age
    sops
    restic
    libressl
    rathole
    screen
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

  # DNS
  services.unbound = {
    enable = true;
  };

  # Crowdsec
  services.crowdsec.enable = false;
  services.crowdsec.settings.general = {
    api = {
      server = {
        listen_uri = "127.0.0.1:8081";
      };
    };
  };

  services.crowdsec-firewall-bouncer.enable = false;
  services.crowdsec-firewall-bouncer.settings = {
    api_url = "http://127.0.0.1:8081/";
  };

  # Container Config
  virtualisation.oci-containers.backend = "docker";

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    daemon.settings = {
      ipv6 = false;
      #firewall-backend = "nftables";
    };
  };

  ## Containers
  virtualisation.oci-containers.containers = {

    uptime = {
      image = "ghcr.io/louislam/uptime-kuma:2.2.1-slim-rootless";
      ports = [ "127.0.0.1:3001:3001" ];
      networks = ["uptime"];
      hostname = "uptime";

      volumes = [
        "uptime_data:/app/data"
      ];

    };

    # this is local with podman compose up
    # freqtrade = {
    #   image = "docker.io/freqtradeorg/freqtrade:stable";
    #   ports = [ "127.0.0.1:8080:8080" ];
    #   networks = ["freqtrade"];
    #   hostname = "freqtrade";

    #   volumes = [
    #     "freqtrade_data:/freqtrade/user_data"
    #   ];

    #   extraOptions = [
    #     "--security-opt=no-new-privileges"
    #   ];

    #   #preRunExtraOptions = [
    #   #  "--runtime=crun"
    #   #];

    #   #entrypoint = "freqtrade trade";

    #   cmd = [
    #     "trade --logfile /freqtrade/user_data/logs/freqtrade.log"
    #     "--db-url sqlite:////freqtrade/user_data/tradesv3.sqlite"
    #     "--config /freqtrade/user_data/config.json"
    #     "--strategy SampleStrategy"
    #   ];
    # };
  };

  # Technitium
  services.technitium-dns-server.enable = false;

  # Adguard
  services.adguardhome = {
    enable = false;
    host = "127.0.0.1";
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      UseDns = true;
    };
  };

  # Caddy
  services.caddy = {
    enable = true;
    globalConfig =
    ''
    debug
    grace_period 5s
    '';
    extraConfig =
    ''
      https://freqtrade.zollerlab.com:443 {
        reverse_proxy 127.0.0.1:8080
      }
      https://status.zollerlab.com:443 {
        reverse_proxy 127.0.0.1:3001
      }
    '';
  };

  # System Config
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

}

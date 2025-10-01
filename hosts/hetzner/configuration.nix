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
  ];

  # Bootloader, need grub for hetzner
  boot.loader.grub.enable = true;

  # Networking  
  networking.hostName = "az-us-hetzner";
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  # Firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    443
  ];

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
      ipv6 = false;
    };
  };

  ## Networks (systemd services oneshot) for containers
  systemd.services."docker-network-whoogle" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect whoogle || docker network create whoogle
    '';
    wantedBy = ["docker-whoogle.target"];
  };

  systemd.services."docker-network-uptime" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect uptime || docker network create uptime
    '';
    wantedBy = ["docker-uptime.target"];
  };
  

  ## Containers
  virtualisation.oci-containers.containers = {

    whoogle = {
      image = "ghcr.io/benbusby/whoogle-search:0.9.4";
      autoStart = true;
      ports = [ "127.0.0.1:5000:5000" ];
      networks = ["whoogle"];
      hostname = "whoogle";

      environment = {
        WHOOGLE_CONFIG_DISABLE = "true";
      };

      extraOptions = [
        "--tmpfs=/config:size=10M,uid=927,gid=927,mode=1700"
        "--tmpfs=/var/lib/tor:size=15M,uid=927,gid=927,mode=1700"
        "--tmpfs=/run/tor:size=1M,uid=927,gid=927,mode=1700"
        "--memory=256m"
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
      ];

    };

    uptime = {
      image = "ghcr.io/louislam/uptime-kuma:2.0.0-beta-slim-rootless.4";
      autoStart = true;
      ports = [ "127.0.0.1:3001:3001" ];
      networks = ["uptime"];
      hostname = "uptime";

      volumes = [
        "uptime_data:/app/data"
      ];

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

  # Caddy
  services.caddy = {
    enable = true;
    extraConfig =
    ''
      https://search.azollerstuff.xyz:443 {
        reverse_proxy 127.0.0.1:5000
      }
      https://status.azollerstuff.xyz:443 {
        reverse_proxy 127.0.0.1:3001
      }
    '';
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

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
    age
    sops
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
  
  # Docker Config
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    daemon.settings = {
      ipv6 = false;
    };
  };

  ## Containers
  virtualisation.oci-containers.containers = {

    searxng = {
      image = "ghcr.io/searxng/searxng:2025.10.20-4295e758c";
      autoStart = true;
      ports = [ "127.0.0.1:8080:8080" ];
      networks = ["searxng"];
      hostname = "searxng";

      environment = {
        SEARXNG_BASE_URL = "https://search.azollerstuff.xyz";
      };

      extraOptions = [
        "--memory=256m"
        "--security-opt=no-new-privileges"
      ];

      volumes = [
        "searxng-data:/var/cache/searxng"
        "searxng-config:/etc/searxng"
      ];

    };

    uptime = {
      image = "ghcr.io/louislam/uptime-kuma:2.0.1-slim-rootless";
      autoStart = true;
      ports = [ "127.0.0.1:3001:3001" ];
      networks = ["uptime"];
      hostname = "uptime";

      volumes = [
        "uptime_data:/app/data"
      ];

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

  # Caddy
  services.caddy = {
    enable = true;
    extraConfig =
    ''
      https://search.azollerstuff.xyz:443 {
        reverse_proxy 127.0.0.1:8080
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

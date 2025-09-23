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
    
    engine = {
  	  volume_path = "/home/azoller/containers/storage/volumes";
  	};
  	
  };

  ## Containers

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
  # no flakes for this
  #system.copySystemConfiguration = true;

  system.stateVersion = "25.05";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

}

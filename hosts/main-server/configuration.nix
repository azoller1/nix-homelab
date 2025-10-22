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
    #../../modules/containers/diun/default.nix
    ../../modules/containers/dozzle-agent/default.nix
    ../../modules/containers/dozzle/default.nix
    ../../modules/containers/beszel/default.nix
    ../../modules/containers/beszel-agent/default.nix
    ../../modules/containers/forgejo/default.nix
    ../../modules/containers/grafana/default.nix
    ../../modules/containers/immich/default.nix
    ../../modules/containers/jellyfin/default.nix
    ../../modules/containers/lldap/default.nix
    ../../modules/containers/paperless/default.nix
    ../../modules/containers/prometheus/default.nix
    ../../modules/containers/signal-api/default.nix
    ../../modules/containers/traefik/default.nix
    ../../modules/containers/viclogs/default.nix
    ../../modules/containers/vicmetrics/default.nix
    ../../modules/containers/pocket-id/default.nix
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

  ## Containers (Imports)

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

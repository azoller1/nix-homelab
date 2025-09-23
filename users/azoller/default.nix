{ config, lib, pkgs, ... }:
{
# Users, default azoller
  users.users.azoller = {
    isNormalUser = true;
    linger = true;
    autoSubUidGidRange = true;
    home = "/home/azoller";
    extraGroups = [ "wheel" "networkmanager" "podman" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIukVfBl4xdLkVYoBsAfsrUQ7aG5qFiObDZbK8j6UGZj azoller@pc-linux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbbugMH2sE7ym1qtLBHY9rHoSgboe/rOFmQSL9zYzVS alexz@laptop"
    ];
  };
  
}
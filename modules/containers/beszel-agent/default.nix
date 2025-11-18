{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."socket-proxy-beszel" = {
      
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

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
        };
    };

    virtualisation.oci-containers.containers."beszel-agent" = {

        image = "ghcr.io/henrygd/beszel/beszel-agent:0.16.1-alpine";
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

        capabilities = {
            SYS_RAWIO = true;
            SYS_ADMIN = true;
        };

        devices = [
            "/dev/nvme0:/dev/nvme0"
        ]

        volumes = [
            "beszel-agent_data:/var/lib/beszel-agent"
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+-alpine$";
            "wud.link.template" = "https://github.com/henrygd/beszel/releases";
        };
    };
}

{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."socket-proxy-traefik" = {
        
        image = "lscr.io/linuxserver/socket-proxy:3.2.10";
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

    virtualisation.oci-containers.containers."traefik" = {

        image = "docker.io/traefik:v3.6.6";
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
            "dozzle"
            "termix"
            "cup"
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
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/traefik/traefik/releases";
            "traefik.enable" = "false";
        };
    };
}

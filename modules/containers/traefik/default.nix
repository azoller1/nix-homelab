{ config, lib, pkgs, ...}:

{
    systemd.services."docker-traefik" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = [
            "docker-network-traefik.service"
            "docker-network-beszel.service"
            "docker-network-lldap.service"
            "docker-network-paperless-traefik.service"
            "docker-network-signal-api.service"
            "docker-network-prom.service"
            "docker-network-grafana.service"
            "docker-network-viclogs.service"
            "docker-network-vicmetrics.service"
            "docker-network-pocket-id.service"
            "docker-network-immich-traefik.service"
            "docker-network-forgejo.service"
            "docker-network-romm.service"
            "docker-network-dozzle.service"
        ];
        requires = [
            "docker-network-traefik.service"
            "docker-network-beszel.service"
            "docker-network-lldap.service"
            "docker-network-paperless-traefik.service"
            "docker-network-signal-api.service"
            "docker-network-prom.service"
            "docker-network-grafana.service"
            "docker-network-viclogs.service"
            "docker-network-vicmetrics.service"
            "docker-network-pocket-id.service"
            "docker-network-immich-traefik.service"
            "docker-network-forgejo.service"
            "docker-network-romm.service"
            "docker-network-dozzle.service"
        ];
        partOf = ["docker-traefik-base.target"];
        wantedBy = ["docker-traefik-base.target"];
    };

    systemd.services."docker-socket-proxy-traefik" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-traefik.service"];
        requires = ["docker-network-traefik.service"];
        partOf = ["docker-traefik-base.target"];
        wantedBy = ["docker-traefik-base.target"];
    };

    systemd.services."docker-network-traefik" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f traefik";
        };

        script = ''
            docker network inspect traefik || docker network create traefik --ipv6
        '';

        partOf = [ "docker-traefik-base.target" ];
        wantedBy = [ "docker-traefik-base.target" ];
    };

    systemd.targets."docker-traefik-base" = {

        unitConfig = {
            Description = "traefik base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."socket-proxy-traefik" = {
        
        image = "lscr.io/linuxserver/socket-proxy:3.2.6";
        #autoStart = true;
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

        image = "docker.io/traefik:v3.5.3";
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
        ];

        ports = [
            "443:9443"
            "80:8080"
            "8088:8080"
        ];

        #autoStart = true;
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
            "diun.enable" = "true";
            "diun.include_tags" = "^\d+\.\d+\..*$";
            "traefik.enable" = "false";
        };
    };
}
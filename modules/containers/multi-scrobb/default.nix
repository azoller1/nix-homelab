{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."scrobbler" = {

        image = "ghcr.io/foxxmd/multi-scrobbler:0.11.4";
        ports = [ "10003:9078" ];
        networks = ["scrobbler"];
        hostname = "scrobbler";

        volumes = [
            "scrobbler_config:/config"
        ];

        environmentFiles = [
            /home/azoller/containers/scrobbler/env
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
            BASE_URL = "https://scrobbler.zollerlab.com";
        };

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.scrobbler.loadbalancer.server.port" = "10003";
            "traefik.http.routers.scrobbler.rule" = "Host(`scrobbler.zollerlab.com`)";
            "traefik.http.routers.scrobbler.entrypoints" = "https";
            "traefik.http.routers.scrobbler.tls" = "true";
            "traefik.http.routers.scrobbler.tls.certresolver" = "le";
            "traefik.http.routers.scrobbler.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.scrobbler.middlewares" = "secheader@file";
        };
    };
}

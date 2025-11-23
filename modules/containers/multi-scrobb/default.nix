{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."scrobbler" = {

        image = "ghcr.io/foxxmd/multi-scrobbler:0.10.3";
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
            BASE_URL = "https://scrobbler.azollerstuff.xyz";
        };

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases";
            "traefik.enable" = "true";
            "traefik.http.services.scrobbler.loadbalancer.server.port" = "10003";
            "traefik.http.routers.scrobbler.rule" = "Host(`scrobbler.azollerstuff.xyz`)";
            "traefik.http.routers.scrobbler.entrypoints" = "https";
            "traefik.http.routers.scrobbler.tls" = "true";
            "traefik.http.routers.scrobbler.tls.certresolver" = "le";
            "traefik.http.routers.scrobbler.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.scrobbler.middlewares" = "secheader@file";
        };
    };
}

{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."jotty" = {

        image = "ghcr.io/fccview/jotty:1.13.1";
        ports = [ "10026:3000" ];
        networks = ["jotty"];
        hostname = "jotty";

        volumes = [
            "data:/app/data:rw"
            "config:/app/config:ro"
            "cache:/app/.next/cache:rw"
        ];

        environment = {
            NODE_ENV = "production";
        };

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/fccview/jotty/releases";
            "traefik.enable" = "true";
            "traefik.http.services.marknote.loadbalancer.server.port" = "10026";
            "traefik.http.routers.marknote.rule" = "Host(`mnotes.azollerstuff.xyz`)";
            "traefik.http.routers.marknote.entrypoints" = "https";
            "traefik.http.routers.marknote.tls" = "true";
            "traefik.http.routers.marknote.tls.certresolver" = "le";
            "traefik.http.routers.marknote.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.marknote.middlewares" = "secheader@file";
        };
    };
}

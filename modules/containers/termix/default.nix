{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."termix" = {

        image = "ghcr.io/lukegus/termix:release-1.9.0";
        networks = ["termix"];
        hostname = "termix";

        volumes = [
            "termix_data:/app/data"
        ];

        environment = {
            PORT = "8080";
        };

        labels = {
            #"kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^release-[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/Termix-SSH/Termix/releases";
            "traefik.enable" = "true";
            "traefik.http.services.termix.loadbalancer.server.port" = "8080";
            "traefik.http.routers.termix.rule" = "Host(`term.azollerstuff.xyz`)";
            "traefik.http.routers.termix.entrypoints" = "https";
            "traefik.http.routers.termix.tls" = "true";
            "traefik.http.routers.termix.tls.certresolver" = "le";
            "traefik.http.routers.termix.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.termix.middlewares" = "secheader@file";
        };
    };
}

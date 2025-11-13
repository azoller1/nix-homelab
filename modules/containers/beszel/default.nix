{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."beszel" = {

        image = "ghcr.io/henrygd/beszel/beszel:0.15.4";
        autoStart = true;
        networks = ["beszel"];
        hostname = "beszel";

        volumes = [
            "beszel_data:/beszel_data"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/henrygd/beszel/releases";
            "traefik.enable" = "true";
            "traefik.http.services.beszel.loadbalancer.server.port" = "8090";
            "traefik.http.routers.beszel.rule" = "Host(`stats.azollerstuff.xyz`)";
            "traefik.http.routers.beszel.entrypoints" = "https";
            "traefik.http.routers.beszel.tls" = "true";
            "traefik.http.routers.beszel.tls.certresolver" = "le";
            "traefik.http.routers.beszel.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.beszel.middlewares" = "secheader@file";
        };
    };
}

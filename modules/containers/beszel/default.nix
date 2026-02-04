{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."beszel" = {

        image = "ghcr.io/henrygd/beszel/beszel:0.18.3";
        autoStart = true;
        networks = ["beszel"];
        hostname = "beszel";

        volumes = [
            "beszel_data:/beszel_data"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.beszel.loadbalancer.server.port" = "8090";
            "traefik.http.routers.beszel.rule" = "Host(`stats.zollerlab.com`)";
            "traefik.http.routers.beszel.entrypoints" = "https";
            "traefik.http.routers.beszel.tls" = "true";
            "traefik.http.routers.beszel.tls.certresolver" = "le";
            "traefik.http.routers.beszel.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.beszel.middlewares" = "secheader@file";
        };
    };
}

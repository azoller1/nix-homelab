{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."pocket-id" = {

        image = "ghcr.io/pocket-id/pocket-id:v2.2.0";
        networks = ["pocket-id"];
        hostname = "pocket-id";

        volumes = [
            "pocket-id_data:/app/data"
        ];

        environmentFiles = [
            /home/azoller/containers/pocket-id/.env
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.pocket-id.loadbalancer.server.port" = "1411";
            "traefik.http.routers.pocket-id.rule" = "Host(`auth.zollerlab.com`)";
            "traefik.http.routers.pocket-id.entrypoints" = "https";
            "traefik.http.routers.pocket-id.tls" = "true";
            "traefik.http.routers.pocket-id.tls.certresolver" = "le";
            "traefik.http.routers.pocket-id.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.pocket-id.middlewares" = "secheader@file";
        };
    };
}

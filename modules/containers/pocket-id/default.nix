{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."pocket-id" = {

        image = "ghcr.io/pocket-id/pocket-id:v1.15.0";
        networks = ["pocket-id"];
        hostname = "pocket-id";

        volumes = [
            "pocket-id_data:/app/data"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.pocket-id
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.pocket-id.loadbalancer.server.port" = "1411";
            "traefik.http.routers.pocket-id.rule" = "Host(`auth.azollerstuff.xyz`)";
            "traefik.http.routers.pocket-id.entrypoints" = "https";
            "traefik.http.routers.pocket-id.tls" = "true";
            "traefik.http.routers.pocket-id.tls.certresolver" = "le";
            "traefik.http.routers.pocket-id.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.pocket-id.middlewares" = "secheader@file";
        };
    };
}

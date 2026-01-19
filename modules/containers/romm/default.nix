{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."romm" = {

        image = "ghcr.io/rommapp/romm:4.5.0";
        #autoStart = true;
        networks = ["romm"];
        hostname = "romm";

        volumes = [
            "romm_data:/romm/resources"
            "romm_redis_data:/redis-data"
            "/mnt/data/romm/library:/romm/library"
            "/mnt/data/romm/assets:/romm/assets"
        ];

        environmentFiles = [
            /home/azoller/containers/romm/.env
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.romm.loadbalancer.server.port" = "8080";
            "traefik.http.routers.romm.rule" = "Host(`romm.azollerstuff.xyz`)";
            "traefik.http.routers.romm.entrypoints" = "https";
            "traefik.http.routers.romm.tls" = "true";
            "traefik.http.routers.romm.tls.certresolver" = "le";
            "traefik.http.routers.romm.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.romm.middlewares" = "secheader@file";
        };
    };
}

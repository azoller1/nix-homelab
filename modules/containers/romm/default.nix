{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."romm" = {

        image = "ghcr.io/rommapp/romm:4.6.1";
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
            "traefik.enable" = "true";
            "traefik.http.services.romm.loadbalancer.server.port" = "8080";
            "traefik.http.routers.romm.rule" = "Host(`romm.zollerlab.com`)";
            "traefik.http.routers.romm.entrypoints" = "https";
            "traefik.http.routers.romm.tls" = "true";
            "traefik.http.routers.romm.tls.certresolver" = "le";
            "traefik.http.routers.romm.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.romm.middlewares" = "secheader@file";
        };
    };
}

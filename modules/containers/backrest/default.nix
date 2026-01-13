{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."backrest" = {

        image = "docker.io/garethgeorge/backrest:v1.10.1-scratch";
        networks = ["backrest"];
        hostname = "backrest";

        volumes = [
            "backrest_data:/data"
            "backrest_config:/config"
            "backrest_cache:/cache"
            "backrest_tmp:/tmp"
        ];

        environment = {
            BACKREST_DATA = "/data";
            BACKREST_CONFIG = "/config/config.json";
            XDG_CACHE_HOME = "/cache";
            TMPDIR = "/tmp";
            TZ = "America/Chicago";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.backrest.loadbalancer.server.port" = "9898";
            "traefik.http.routers.backrest.rule" = "Host(`backups.zollerlab.com`)";
            "traefik.http.routers.backrest.entrypoints" = "https";
            "traefik.http.routers.backrest.tls" = "true";
            "traefik.http.routers.backrest.tls.certresolver" = "le";
            "traefik.http.routers.backrest.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.backrest.middlewares" = "secheader@file";
        };
    };
}

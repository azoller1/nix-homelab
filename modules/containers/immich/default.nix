{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."immich" = {

        image = "ghcr.io/immich-app/immich-server:v2.5.3";
        networks = [
            "immich"
            "immich-traefik"
        ];

        hostname = "immich-server";

        dependsOn = [
            "immich-db"
            "immich-redis"
        ];


        volumes = [
            "/mnt/hdd/media/photos-uploaded:/data"
            "/mnt/hdd/media/photos:/mnt/media/main-photos:ro"
            "/etc/localtime:/etc/localtime:ro"
        ];

        environmentFiles = [
            /home/azoller/containers/immich/.env
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.docker.network" = "immich-traefik";
            "traefik.http.services.immich-server.loadbalancer.server.port" = "2283";
            "traefik.http.routers.immich-server.rule" = "Host(`photos.zollerlab.com`)";
            "traefik.http.routers.immich-server.entrypoints" = "https";
            "traefik.http.routers.immich-server.tls" = "true";
            "traefik.http.routers.immich-server.tls.certresolver" = "le";
            "traefik.http.routers.immich-server.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.immich-server.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."immich-machine-learning" = {

        image = "ghcr.io/immich-app/immich-machine-learning:v2.5.3";
        networks = ["immich"];
        hostname = "immich-machine-learning";

        volumes = [
            "immich_cache:/cache"
        ];

        environmentFiles = [
            /home/azoller/containers/immich/.env
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."immich-redis" = {

        image = "docker.io/valkey/valkey:9-trixie";
        networks = ["immich"];
        hostname = "immich-redis";

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."immich-db" = {

        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        networks = ["immich"];
        hostname = "immich-db";

        volumes = [
            "immich_db:/var/lib/postgresql/data"
        ];

        environment = {
            POSTGRES_DB = "immich";
        };

        environmentFiles = [
            /home/azoller/containers/immich/.env
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

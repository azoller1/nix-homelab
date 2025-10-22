{ config, lib, pkgs, ...}:

{
    systemd.services."docker-immich" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-immich.service"];
        requires = ["docker-network-immich.service"];
        partOf = ["docker-immich-base.target"];
        wantedBy = ["docker-immich-base.target"];
    };

    systemd.services."docker-immich-machine-learning" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-immich.service"];
        requires = ["docker-network-immich.service"];
        partOf = ["docker-immich-base.target"];
        wantedBy = ["docker-immich-base.target"];
    };

    systemd.services."docker-immich-redis" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-immich.service"];
        requires = ["docker-network-immich.service"];
        partOf = ["docker-immich-base.target"];
        wantedBy = ["docker-immich-base.target"];
    };

    systemd.services."docker-immich-db" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-immich.service"];
        requires = ["docker-network-immich.service"];
        partOf = ["docker-immich-base.target"];
        wantedBy = ["docker-immich-base.target"];
    };

    systemd.services."docker-network-immich" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f immich";
        };

        script = ''
            docker network inspect immich-traefik || docker network create immich-traefik --ipv6
            docker network inspect immich || docker network create immich --ipv6 
        '';

        partOf = [ "docker-immich-base.target" ];
        wantedBy = [ "docker-immich-base.target" ];
    };

    systemd.targets."docker-immich-base" = {

        unitConfig = {
            Description = "immich base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."immich" = {

        image = "ghcr.io/immich-app/immich-server:v2.1.0";
        #autoStart = true;
        networks = [
            "immich"
            "immich-traefik"
        ];

        hostname = "immich-server";

        dependsOn = [
            "immich-db"
            "immich-redis"
        ];

        devices = [
            "/dev/dri:/dev/dri"
        ];

        volumes = [
            "/mnt/hdd/media/photos-uploaded:/data"
            "/mnt/hdd/media/photos:/mnt/media/main-photos:ro"
            "/etc/localtime:/etc/localtime:ro"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
        ];

        labels = {
            "diun.enable" = "true";
            "diun.include_tags" = "^\d+\.\d+\..*$";
            "traefik.enable" = "true";
            "traefik.docker.network" = "immich-traefik";
            "traefik.http.services.immich-server.loadbalancer.server.port" = "2283";
            "traefik.http.routers.immich-server.rule" = "Host(`photos.azollerstuff.xyz`)";
            "traefik.http.routers.immich-server.entrypoints" = "https";
            "traefik.http.routers.immich-server.tls" = "true";
            "traefik.http.routers.immich-server.tls.certresolver" = "le";
            "traefik.http.routers.immich-server.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.immich-server.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."immich-machine-learning" = {

        image = "ghcr.io/immich-app/immich-machine-learning:v2.1.0";
        #autoStart = true;
        networks = ["immich"];
        hostname = "immich-machine-learning";

        volumes = [
            "immich_cache:/cache"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
        ];

        labels = {
            "diun.enable" = "true";
            "traefik.enable" = "false";
            "diun.include_tags" = "^\d+\.\d+\..*$";
        };
    };

    virtualisation.oci-containers.containers."immich-redis" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        #autoStart = true;
        networks = ["immich"];
        hostname = "immich-redis";

        labels = {
            "traefik.enable" = "false";
            "diun.include_tags" = "^\d+\.\d+\..*$";
        };
    };

    virtualisation.oci-containers.containers."immich-db" = {

        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        #autoStart = true;
        networks = ["immich"];
        hostname = "immich-db";

        volumes = [
            "immich_db:/var/lib/postgresql/data"
        ];

        environment = {
            POSTGRES_DB = "immich";
        };

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.immich
        ];

        labels = {
            "traefik.enable" = "false";
            "diun.include_tags" = "^\d+\.\d+\..*$";
        };
    };
}
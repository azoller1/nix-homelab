{ config, lib, pkgs, ...}:

{
    systemd.services."docker-wger" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wger.service"];
        requires = ["docker-network-wger.service"];
        partOf = ["docker-wger-base.target"];
        wantedBy = ["docker-wger-base.target"];
    };

    systemd.services."docker-wger-nginx" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wger.service"];
        requires = ["docker-network-wger.service"];
        partOf = ["docker-wger-base.target"];
        wantedBy = ["docker-wger-base.target"];
    };

    systemd.services."docker-wger-valkey" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wger.service"];
        requires = ["docker-network-wger.service"];
        partOf = ["docker-wger-base.target"];
        wantedBy = ["docker-wger-base.target"];
    };

    systemd.services."docker-wger-celery-worker" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wger.service"];
        requires = ["docker-network-wger.service"];
        partOf = ["docker-wger-base.target"];
        wantedBy = ["docker-wger-base.target"];
    };

    systemd.services."docker-wger-celery-beat" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wger.service"];
        requires = ["docker-network-wger.service"];
        partOf = ["docker-wger-base.target"];
        wantedBy = ["docker-wger-base.target"];
    };

    systemd.services."docker-network-wger" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f wger";
        };

        script = ''
            docker network inspect wger || docker network create wger --ipv6
        '';

        partOf = [ "docker-wger-base.target" ];
        wantedBy = [ "docker-wger-base.target" ];
    };

    systemd.targets."docker-wger-base" = {

        unitConfig = {
            Description = "wger base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."wger" = {

        image = "docker.io/wger/server:2.3-dev";
        networks = ["wger"];
        hostname = "wger";

        volumes = [
            "wger_static:/home/wger/static"
            "wger_media:/home/wger/media"
        ];

        dependsOn = [
            "wger-valkey"
        ];

        environmentFiles = [
            "/home/azoller/containers/wger/env"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."wger-nginx" = {

        image = "docker.io/nginx:1.28.0";
        ports = [ "10017:80" ];
        networks = ["wger"];
        hostname = "wger-nginx";

        volumes = [
            "wger_static:/wger/static:ro"
            "wger_media:/wger/media:ro"
            "/home/azoller/containers/wger/nginx.conf:/etc/nginx/conf.d/default.conf"
        ];

        dependsOn = [
            "wger"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.wger.loadbalancer.server.port" = "10017";
            "traefik.http.routers.wger.rule" = "Host(`workouts.azollerstuff.xyz`)";
            "traefik.http.routers.wger.entrypoints" = "https";
            "traefik.http.routers.wger.tls" = "true";
            "traefik.http.routers.wger.tls.certresolver" = "le";
            "traefik.http.routers.wger.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.wger.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."wger-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["wger"];
        hostname = "wger-valkey";

        volumes = [
            "wger_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel notice"
            "--maxmemory 1gb"
            "--protected-mode no"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."wger-celery-worker" = {

        image = "docker.io/wger/server:2.3-dev";
        networks = ["wger"];
        hostname = "wger-celery-worker";
        cmd = ["/start-worker"];

        volumes = [
            "wger_media:/home/wger/media"
        ];

        dependsOn = [
            "wger"
        ];

        environmentFiles = [
            "/home/azoller/containers/wger/env"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."wger-celery-beat" = {

        image = "docker.io/wger/server:2.3-dev";
        networks = ["wger"];
        hostname = "wger-celery-beat";
        cmd = ["/start-beat"];

        volumes = [
            "wger_celery-beat:/home/wger/beat"
        ];

        dependsOn = [
            "wger-celery-worker"
        ];

        environmentFiles = [
            "/home/azoller/containers/wger/env"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}
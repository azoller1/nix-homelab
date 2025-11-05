{ config, lib, pkgs, ...}:

{
    systemd.services."docker-dawarich" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-dawarich.service"];
        requires = ["docker-network-dawarich.service"];
        partOf = ["docker-dawarich-base.target"];
        wantedBy = ["docker-dawarich-base.target"];
    };

    systemd.services."docker-dawarich-side" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-dawarich.service"];
        requires = ["docker-network-dawarich.service"];
        partOf = ["docker-dawarich-base.target"];
        wantedBy = ["docker-dawarich-base.target"];
    };

    systemd.services."docker-dawarich-valkey" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-dawarich.service"];
        requires = ["docker-network-dawarich.service"];
        partOf = ["docker-dawarich-base.target"];
        wantedBy = ["docker-dawarich-base.target"];
    };

    systemd.services."docker-network-dawarich" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f dawarich";
        };

        script = ''
            docker network inspect dawarich || docker network create dawarich --ipv6
        '';

        partOf = [ "docker-dawarich-base.target" ];
        wantedBy = [ "docker-dawarich-base.target" ];
    };

    systemd.targets."docker-dawarich-base" = {

        unitConfig = {
            Description = "dawarich base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."dawarich-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["dawarich"];
        hostname = "dawarich-valkey";

        volumes = [
            "dawarich_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel warning"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."dawarich" = {

        image = "docker.io/freikin/dawarich:0.34.0";
        ports = [ "10014:3000" ];
        networks = ["dawarich"];
        hostname = "dawarich_app";

        volumes = [
            "dawarich_public:/var/app/public"
            "dawarich_watched:/var/app/tmp/imports/watched"
            "dawarich_data:/var/app/storage"
        ];

        #extraOptions = [
        #    "--tty"
        #    "--interactive"
        #];

        cmd = ["bin/rails" "server" "-p" "3000" "-b" "::"];

        dependsOn = [
            "dawarich-valkey"
        ];

        entrypoint = "web-entrypoint.sh";

        environmentFiles = [
            "/home/azoller/containers/dawarich/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/Freika/dawarich/releases";
            "traefik.enable" = "true";
            "traefik.http.services.dawarich.loadbalancer.server.port" = "10014";
            "traefik.http.routers.dawarich.rule" = "Host(`maps.azollerstuff.xyz`)";
            "traefik.http.routers.dawarich.entrypoints" = "https";
            "traefik.http.routers.dawarich.tls" = "true";
            "traefik.http.routers.dawarich.tls.certresolver" = "le";
            "traefik.http.routers.dawarich.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.dawarich.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."dawarich-side" = {

        image = "docker.io/freikin/dawarich:0.34.0";
        networks = ["dawarich"];
        hostname = "dawarich_sidekiq";

        volumes = [
            "dawarich_public:/var/app/public"
            "dawarich_watched:/var/app/tmp/imports/watched"
            "dawarich_data:/var/app/storage"
        ];

        #extraOptions = [
        #    "--tty"
        #    "--interactive"
        #];

        cmd = ["bundle" "exec" "sidekiq"];

        dependsOn = [
            "dawarich-valkey"
            "dawarich"
        ];

        entrypoint = "sidekiq-entrypoint.sh";

        environmentFiles = [
            "/home/azoller/containers/dawarich/side-env"
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/Freika/dawarich/releases";
        };
    };
}
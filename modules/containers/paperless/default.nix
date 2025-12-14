{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."paperless" = {

        image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.2";
        networks = [
            "paperless"
            "paperless-traefik"
        ];

        #autoStart = true;
        hostname = "paperless";

        dependsOn = [
            "paper-valkey"
            "paper-tika"
            "paper-gotenberg"
        ];

        volumes = [
            "paperless_data:/usr/src/paperless/data"
            "paperless_media:/usr/src/paperless/media"
            "/mnt/hdd/paperless/export:/usr/src/paperless/export"
            "/mnt/hdd/paperless/consume:/usr/src/paperless/consume"
        ];

        environment = {
            PAPERLESS_REDIS = "redis://paper-valkey:6379";
            PAPERLESS_TIKA_ENABLED = "1";
            PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paper-gotenberg:3000";
            PAPERLESS_TIKA_ENDPOINT = "http://paper-tika:9998";
        };

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.paperless
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/paperless-ngx/paperless-ngx/releases";
            "traefik.enable" = "true";
            "traefik.docker.network" = "paperless-traefik";
            "traefik.http.services.paperless.loadbalancer.server.port" = "8000";
            "traefik.http.routers.paperless.rule" = "Host(`papers.azollerstuff.xyz`)";
            "traefik.http.routers.paperless.entrypoints" = "https";
            "traefik.http.routers.paperless.tls" = "true";
            "traefik.http.routers.paperless.tls.certresolver" = "le";
            "traefik.http.routers.paperless.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.paperless.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."paper-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        #autoStart = true;
        networks = ["paperless"];
        hostname = "paper-valkey";

        volumes = [
            "paperless_valkey_data:/data"
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

    virtualisation.oci-containers.containers."paper-tika" = {

        image = "docker.io/apache/tika:3.2.2.0";
        #autoStart = true;
        networks = ["paperless"];
        hostname = "paper-tika";

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."paper-gotenberg" = {

        image = "docker.io/gotenberg/gotenberg:8.20.1";
        #autoStart = true;
        networks = ["paperless"];
        hostname = "paper-gotenberg";

        cmd = [
            "gotenberg"
            "--chromium-disable-javascript=true"
            "--chromium-allow-list=file:///tmp/.*"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

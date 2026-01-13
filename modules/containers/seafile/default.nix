{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."seafile" = {

        image = "docker.io/seafileltd/seafile-pro-mc:13.0-latest";
        networks = ["seafile"];
        hostname = "seafile";

        volumes = [
            "seafile_data:/shared"
        ];

        environmentFiles = [
            "/home/azoller/containers/seafile/.env"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.seafile.loadbalancer.server.port" = "80";
            "traefik.http.routers.seafile.rule" = "Host(`seafile.zollerlab.com`)";
            "traefik.http.routers.seafile.entrypoints" = "https";
            "traefik.http.routers.seafile.tls" = "true";
            "traefik.http.routers.seafile.tls.certresolver" = "le";
            "traefik.http.routers.seafile.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.seafile.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."seadoc" = {

        image = "docker.io/seafileltd/sdoc-server:2.0-latest";
        networks = ["seafile"];
        hostname = "seadoc";

        volumes = [
            "seafile-doc_data:/shared"
        ];

        environmentFiles = [
            "/home/azoller/containers/seafile/.env"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.seadoc.loadbalancer.server.port" = "8888";
            "traefik.http.routers.seadoc.rule" = "Host(`seafile.zollerlab.com`) && PathPrefix(`/sdoc-server`) && PathPrefix(`/socket.io`)";
            "traefik.http.routers.seadoc.entrypoints" = "https";
            "traefik.http.routers.seadoc.tls" = "true";
            "traefik.http.routers.seadoc.tls.certresolver" = "le";
            "traefik.http.routers.seadoc.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.seadoc.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."seafile-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["seafile"];
        hostname = "seafile-valkey";

        volumes = [
            "seafile_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel notice"
            "--maxmemory 512mb"
            "--protected-mode no"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

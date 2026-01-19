{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."outline" = {

        image = "docker.io/outlinewiki/outline:1.3.0";
        ports = [ "10006:3000" ];
        networks = [ "outline" ];
        hostname = "outline";

        dependsOn = [
            "outline-valkey"
        ];

        volumes = [
            "outline_data:/var/lib/outline/data"
        ];

        environmentFiles = [
            "/home/azoller/containers/outline/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/outline/outline/releases";
            "traefik.enable" = "true";
            "traefik.http.services.outline.loadbalancer.server.port" = "10006";
            "traefik.http.routers.outline.rule" = "Host(`wiki.azollerstuff.xyz`)";
            "traefik.http.routers.outline.entrypoints" = "https";
            "traefik.http.routers.outline.tls" = "true";
            "traefik.http.routers.outline.tls.certresolver" = "le";
            "traefik.http.routers.outline.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.outline.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."outline-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["outline"];
        hostname = "outline-valkey";

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel warning"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

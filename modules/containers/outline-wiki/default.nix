{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."outline" = {

        image = "docker.io/outlinewiki/outline:1.5.0";
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
            "traefik.enable" = "true";
            "traefik.http.services.outline.loadbalancer.server.port" = "10006";
            "traefik.http.routers.outline.rule" = "Host(`wiki.zollerlab.com`)";
            "traefik.http.routers.outline.entrypoints" = "https";
            "traefik.http.routers.outline.tls" = "true";
            "traefik.http.routers.outline.tls.certresolver" = "le";
            "traefik.http.routers.outline.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.outline.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."outline-valkey" = {

        image = "docker.io/valkey/valkey:9-trixie";
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

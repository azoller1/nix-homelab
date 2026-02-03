{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."sure" = {

        image = "git.zollerlab.com/azoller/sure:0.6.7";
        ports = [ "10004:3000" ];
        networks = ["sure"];
        hostname = "sure";

        volumes = [
            "sure_data:/rails/storage"
        ];

        environmentFiles = [
            "/home/azoller/containers/sure-finances/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.sure.loadbalancer.server.port" = "10004";
            "traefik.http.routers.sure.rule" = "Host(`finances.zollerlab.com`)";
            "traefik.http.routers.sure.entrypoints" = "https";
            "traefik.http.routers.sure.tls" = "true";
            "traefik.http.routers.sure.tls.certresolver" = "le";
            "traefik.http.routers.sure.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.sure.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."sure-worker" = {

        image = "git.zollerlab.com/azoller/sure:0.6.7";
        networks = ["sure"];
        hostname = "sure-worker";

        volumes = [
            "sure_data:/rails/storage"
        ];

        cmd = [
            "bundle"
            "exec"
            "sidekiq"
        ];

        environmentFiles = [
            "/home/azoller/containers/sure-finances/env"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."sure-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["sure"];
        hostname = "sure-valkey";

        volumes = [
            "sure_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel notice"
            "--maxmemory 256mb"
            "--protected-mode no"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

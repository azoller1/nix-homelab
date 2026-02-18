{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."yamtrack-valkey" = {

        image = "docker.io/valkey/valkey:9-trixie";
        networks = ["yamtrack"];
        hostname = "yamtrack-valkey";

        volumes = [
            "yamtrack_valkey_data:/data"
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

    virtualisation.oci-containers.containers."yamtrack" = {

        image = "ghcr.io/fuzzygrim/yamtrack:0.25.0";
        ports = [ "10013:8000" ];
        networks = ["yamtrack"];
        hostname = "yamtrack";

        volumes = [
            "yamtrack_data:/yamtrack/db"
        ];

        environment = {
            TZ = "America/Chicago";
            REDIS_URL = "redis://yamtrack-valkey:6379";
        };

        environmentFiles = [
            "/home/azoller/containers/yamtrack/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.yamtrack.loadbalancer.server.port" = "10013";
            "traefik.http.routers.yamtrack.rule" = "Host(`yamtrack.zollerlab.com`)";
            "traefik.http.routers.yamtrack.entrypoints" = "https";
            "traefik.http.routers.yamtrack.tls" = "true";
            "traefik.http.routers.yamtrack.tls.certresolver" = "le";
            "traefik.http.routers.yamtrack.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.yamtrack.middlewares" = "secheader@file";
        };
    };
}
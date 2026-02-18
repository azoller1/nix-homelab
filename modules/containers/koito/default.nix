{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."koito" = {

        image = "docker.io/gabehf/koito:v0.1.7";
        ports = [ "10002:4110" ];
        networks = ["koito"];
        hostname = "koito";

        volumes = [
            "koito_data:/etc/koito"
        ];

        environmentFiles = [
            /home/azoller/containers/koito/env
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.koito.loadbalancer.server.port" = "10002";
            "traefik.http.routers.koito.rule" = "Host(`koito.zollerlab.com`)";
            "traefik.http.routers.koito.entrypoints" = "https";
            "traefik.http.routers.koito.tls" = "true";
            "traefik.http.routers.koito.tls.certresolver" = "le";
            "traefik.http.routers.koito.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.koito.middlewares" = "secheader@file";
        };
    };
}
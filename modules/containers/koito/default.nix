{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."koito" = {

        image = "docker.io/gabehf/koito:v0.0.14";
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
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/gabehf/Koito/releases";
            "traefik.enable" = "true";
            "traefik.http.services.koito.loadbalancer.server.port" = "10002";
            "traefik.http.routers.koito.rule" = "Host(`koito.azollerstuff.xyz`)";
            "traefik.http.routers.koito.entrypoints" = "https";
            "traefik.http.routers.koito.tls" = "true";
            "traefik.http.routers.koito.tls.certresolver" = "le";
            "traefik.http.routers.koito.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.koito.middlewares" = "secheader@file";
        };
    };
}
{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."tuwunel" = {

        image = "ghcr.io/matrix-construct/tuwunel:v1.5.0";
        networks = ["matrix"];
        hostname = "tuwunel";

        volumes = [
            "tuwunel_data:/var/lib/tuwunel/"
        ];

        environmentFiles = [
            /home/azoller/containers/tuwunel/env
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.tuwunel.loadbalancer.server.port" = "6167";
            "traefik.http.routers.tuwunel.rule" = "Host(`zollerlab.com`) || Host(`zollerlab.com`) && PathPrefix(`/.well-known/matrix`)";
            "traefik.http.routers.tuwunel.entrypoints" = "https";
            "traefik.http.routers.tuwunel.tls" = "true";
            "traefik.http.routers.tuwunel.tls.certresolver" = "le";
            "traefik.http.routers.tuwunel.tls.domains[0].main" = "zollerlab.com";
            "traefik.http.routers.tuwunel.middlewares" = "secheader@file";
        };
    };
}
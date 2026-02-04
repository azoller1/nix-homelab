{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."vw" = {

        image = "ghcr.io/dani-garcia/vaultwarden:1.35.2";
        #autoStart = true;
        ports = [ "10003:80" ];
        networks = ["vw"];
        hostname = "vw";

        volumes = [
            "vw_data:/data"
        ];

        environment = {
            ROCKET_ADDRESS = "0.0.0.0";
        };

        environmentFiles = [
            /home/azoller/containers/vw/.env
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.vw.loadbalancer.server.port" = "10003";
            "traefik.http.routers.vw.rule" = "Host(`vault.zollerlab.com`)";
            "traefik.http.routers.vw.entrypoints" = "https";
            "traefik.http.routers.vw.tls" = "true";
            "traefik.http.routers.vw.tls.certresolver" = "le";
            "traefik.http.routers.vw.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.vw.middlewares" = "secheader@file";
        };
    };
}
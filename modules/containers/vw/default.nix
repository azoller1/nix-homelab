{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."vw" = {

        image = "ghcr.io/dani-garcia/vaultwarden:1.35.0";
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
            /home/azoller/nix-homelab/hosts/node1/.env.secret.vw
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/dani-garcia/vaultwarden/releases";
            "traefik.enable" = "true";
            "traefik.http.services.vw.loadbalancer.server.port" = "10003";
            "traefik.http.routers.vw.rule" = "Host(`vault.azollerstuff.xyz`)";
            "traefik.http.routers.vw.entrypoints" = "https";
            "traefik.http.routers.vw.tls" = "true";
            "traefik.http.routers.vw.tls.certresolver" = "le";
            "traefik.http.routers.vw.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.vw.middlewares" = "secheader@file";
        };
    };
}
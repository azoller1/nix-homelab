{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."apprise" = {

        image = "ghcr.io/caronc/apprise:1.3.0";
        #autoStart = true;
        ports = [ "10000:8000" ];
        networks = ["apprise"];
        hostname = "apprise";

        volumes = [
            "apprise_config:/config"
            "apprise_plugin:/plugin"
            "apprise_attach:/attach"
            "apprise_data:/config/store"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/node1/.env.secret.apprise
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/caronc/apprise-api/releases";
            "traefik.enable" = "true";
            "traefik.http.services.apprise.loadbalancer.server.port" = "10000";
            "traefik.http.routers.apprise.rule" = "Host(`apprise.azollerstuff.xyz`)";
            "traefik.http.routers.apprise.entrypoints" = "https";
            "traefik.http.routers.apprise.tls" = "true";
            "traefik.http.routers.apprise.tls.certresolver" = "le";
            "traefik.http.routers.apprise.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.apprise.middlewares" = "secheader@file";
        };
    };
}
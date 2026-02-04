{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."lldap" = {

        image = "ghcr.io/lldap/lldap:v0.6.2-alpine-rootless";
        networks = ["lldap"];
        #autoStart = true;
        ports = ["3890:3890"];
        hostname = "lldap";

        volumes = [
            "lldap_data:/data"
        ];

        environment = {
            UID = "1000";
            GID = "100";
            TZ = "America/Chicago";
        };

        environmentFiles = [
            /home/azoller/containers/lldap/.env
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.lldap.loadbalancer.server.port" = "17170";
            "traefik.http.routers.lldap.rule" = "Host(`lldap.zollerlab.com`)";
            "traefik.http.routers.lldap.entrypoints" = "https";
            "traefik.http.routers.lldap.tls" = "true";
            "traefik.http.routers.lldap.tls.certresolver" = "le";
            "traefik.http.routers.lldap.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.lldap.middlewares" = "secheader@file";
        };
    };
}
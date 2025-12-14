{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."geopulse-ui" = {

        image = "ghcr.io/tess1o/geopulse-ui:1.9.1";
        ports = [ "10000:80" ];
        networks = ["geopulse"];
        hostname = "geopulse-ui";

        dependsOn = [
            "geopulse"
        ];

        environmentFiles = [
            /home/azoller/containers/geopulse/.env
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.7";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/tess1o/geopulse/releases";
            "traefik.enable" = "true";
            "traefik.http.services.geopulse.loadbalancer.server.port" = "10000";
            "traefik.http.routers.geopulse.rule" = "Host(`geopulse.azollerstuff.xyz`)";
            "traefik.http.routers.geopulse.entrypoints" = "https";
            "traefik.http.routers.geopulse.tls" = "true";
            "traefik.http.routers.geopulse.tls.certresolver" = "le";
            "traefik.http.routers.geopulse.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.geopulse.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."geopulse" = {

        image = "ghcr.io/tess1o/geopulse-backend:1.9.1-native";
        networks = ["geopulse"];
        hostname = "geopulse";

        volumes = [
            "geopulse_keys:/app/keys"
        ];

        environmentFiles = [
            /home/azoller/containers/geopulse/.env
        ];

        extraOptions = [
            "--memory=512m"
        ];
    };
}

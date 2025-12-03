{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."mealie" = {

        image = "ghcr.io/mealie-recipes/mealie:v3.6.0";
        ports = [ "10011:9000" ];
        networks = ["mealie"];
        hostname = "mealie";

        volumes = [
            "mealie_data:/app/data/"
        ];

        environment = {
            ALLOW_SIGNUP = "false";
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
            BASE_URL = "https://recipes.azollerstuff.xyz";
        };

        extraOptions = [
            "--memory=1024m"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/mealie-recipes/mealie/releases";
            "traefik.enable" = "true";
            "traefik.http.services.mealie.loadbalancer.server.port" = "10011";
            "traefik.http.routers.mealie.rule" = "Host(`recipes.azollerstuff.xyz`)";
            "traefik.http.routers.mealie.entrypoints" = "https";
            "traefik.http.routers.mealie.tls" = "true";
            "traefik.http.routers.mealie.tls.certresolver" = "le";
            "traefik.http.routers.mealie.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.mealie.middlewares" = "secheader@file";
        };
    };
}

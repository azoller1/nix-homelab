{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."signal-api" = {

        image = "docker.io/bbernhard/signal-cli-rest-api:0.96";
        networks = ["signal-api"];
        #autoStart = true;
        hostname = "signal-api";

        volumes = [
            "signal-api_data:/home/.local/share/signal-cli"
        ];

        environment = {
            MODE = "json-rpc";
        };

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.signal-api.loadbalancer.server.port" = "8080";
            "traefik.http.routers.signal-api.rule" = "Host(`signal-api.azollerstuff.xyz`)";
            "traefik.http.routers.signal-api.entrypoints" = "https";
            "traefik.http.routers.signal-api.tls" = "true";
            "traefik.http.routers.signal-api.tls.certresolver" = "le";
            "traefik.http.routers.signal-api.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.signal-api.middlewares" = "secheader@file";
        };
    };
}
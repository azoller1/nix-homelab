{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."nodered" = {

        image = "docker.io/nodered/node-red:4.1.2";
        #autoStart = true;
        ports = [ "10001:1880" ];
        networks = ["nodered"];
        hostname = "nodered";

        environment = {
            TZ = "America/Chicago";
        };

        volumes = [
            "nodered_data:/data"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.nodered.loadbalancer.server.port" = "10001";
            "traefik.http.routers.nodered.rule" = "Host(`node-red.azollerstuff.xyz`)";
            "traefik.http.routers.nodered.entrypoints" = "https";
            "traefik.http.routers.nodered.tls" = "true";
            "traefik.http.routers.nodered.tls.certresolver" = "le";
            "traefik.http.routers.nodered.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.nodered.middlewares" = "secheader@file,oidc-auth-nodered@file";
        };
    };
}
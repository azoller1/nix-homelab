{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."forgejo" = {

        image = "codeberg.org/forgejo/forgejo:14.0.2-rootless";
        networks = ["forgejo"];
        ports = ["2222:2222"];
        hostname = "forgejo";

        environment = {
            USER_UID = "1000";
            USER_GID = "100";
        };

        volumes = [
            "forgejo:/var/lib/gitea"
            "/home/azoller/containers/forgejo/app.ini:/var/lib/gitea/custom/conf/app.ini"
            "/etc/timezone:/etc/timezone:ro"
            "/etc/localtime:/etc/localtime:ro"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.forgejo.service" = "forgejo";
            "traefik.http.services.forgejo.loadbalancer.server.port" = "3000";
            "traefik.http.routers.forgejo.rule" = "Host(`git.zollerlab.com`)";
            "traefik.http.routers.forgejo.entrypoints" = "https";
            "traefik.http.routers.forgejo.tls" = "true";
            "traefik.http.routers.forgejo.tls.certresolver" = "le";
            "traefik.http.routers.forgejo.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.forgejo.middlewares" = "secheader@file";
        };
    };
}

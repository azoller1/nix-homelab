{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."tasktrove" = {

        image = "ghcr.io/dohsimpson/tasktrove:v0.11.1";
        ports = [ "10012:3000" ];
        networks = ["tasktrove"];
        hostname = "tasktrove";

        volumes = [
            "tasktrove:/app/data"
        ];

        environmentFiles = [
            "/home/azoller/containers/tasktrove/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/dohsimpson/TaskTrove/releases";
            "traefik.enable" = "true";
            "traefik.http.services.tasktrove.loadbalancer.server.port" = "10012";
            "traefik.http.routers.tasktrove.rule" = "Host(`tasks.azollerstuff.xyz`)";
            "traefik.http.routers.tasktrove.entrypoints" = "https";
            "traefik.http.routers.tasktrove.tls" = "true";
            "traefik.http.routers.tasktrove.tls.certresolver" = "le";
            "traefik.http.routers.tasktrove.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.tasktrove.middlewares" = "secheader@file";
        };
    };
}
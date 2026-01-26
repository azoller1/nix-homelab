{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."patchmon-front" = {

        image = "git.azollerstuff.xyz/azoller/patchmon-front:1.3.7";
        networks = ["patchmon" "patchmon-traefik"];
        hostname = "patchmon-front";

        volumes = [
            "patchmon_branding_assets:/usr/share/nginx/html/assets"
        ];

        environment = {
            BACKEND_HOST = "patchmon-back";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.docker.network" = "patchmon-traefik";
            "traefik.http.routers.patchmon-front.service" = "patchmon-front";
            "traefik.http.services.patchmon-front.loadbalancer.server.port" = "3000";
            "traefik.http.routers.patchmon-front.rule" = "Host(`patchmon.zollerlab.com`)";
            "traefik.http.routers.patchmon-front.entrypoints" = "https";
            "traefik.http.routers.patchmon-front.tls" = "true";
            "traefik.http.routers.patchmon-front.tls.certresolver" = "le";
            "traefik.http.routers.patchmon-front.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.patchmon-front.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."patchmon-back" = {

        image = "git.azollerstuff.xyz/azoller/patchmon-back:1.3.7";
        networks = ["patchmon"];
        hostname = "patchmon-back";

        environmentFiles = [
            /home/azoller/containers/patchmon/.env
        ];

        volumes = [
            "patchmon_branding_assets:/app/assets"
            "patchmon_agents:/app/agents"
        ];
    };

    virtualisation.oci-containers.containers."redis-patchmon" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["patchmon"];
        hostname = "redis-patchmon";

        volumes = [
            "patchmon_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel notice"
            "--maxmemory 256mb"
            "--protected-mode no"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

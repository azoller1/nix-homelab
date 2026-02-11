{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."ntfy" = {

        image = "git.zollerlab.com/azoller/ntfy:2.17.0";
        networks = ["ntfy"];
        hostname = "ntfy";

        volumes = [
            "ntfy_data:/app/data"
        ];

        environment = {
            TZ = "America/Chicago";
            NTFY_BASE_URL = "https://ntfy.zollerlab.com";
            NTFY_LISTEN_HTTP = "0.0.0.0:8080";
            NTFY_CACHE_FILE = "/app/data/cache.db";
            NTFY_BEHIND_PROXY = "true";
            NTFY_UPSTREAM_BASE_URL = "https://ntfy.zollerlab.com";
        };

        cmd = [
            "ntfy"
            "serve"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.ntfy.loadbalancer.server.port" = "8080";
            "traefik.http.routers.ntfy.rule" = "Host(`ntfy.zollerlab.com`)";
            "traefik.http.routers.ntfy.entrypoints" = "https";
            "traefik.http.routers.ntfy.tls" = "true";
            "traefik.http.routers.ntfy.tls.certresolver" = "le";
            "traefik.http.routers.ntfy.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.ntfy.middlewares" = "secheader@file";
        };
    };
}
{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."lubelogger" = {

        image = "ghcr.io/hargata/lubelogger:v1.5.8";
        ports = [ "10007:8080" ];
        networks = ["lubelogger"];
        hostname = "lubelogger";

        volumes = [
            "lubelogger_data:/App/data"
            "lubelogger_keys:/root/.aspnet/DataProtection-Keys"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.lubelogger.loadbalancer.server.port" = "10007";
            "traefik.http.routers.lubelogger.rule" = "Host(`vehicles.zollerlab.com`)";
            "traefik.http.routers.lubelogger.entrypoints" = "https";
            "traefik.http.routers.lubelogger.tls" = "true";
            "traefik.http.routers.lubelogger.tls.certresolver" = "le";
            "traefik.http.routers.lubelogger.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.lubelogger.middlewares" = "secheader@file";
        };
    };
}

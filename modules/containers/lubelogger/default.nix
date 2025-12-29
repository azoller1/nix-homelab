{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."lubelogger" = {

        image = "ghcr.io/hargata/lubelogger:v1.5.6";
        ports = [ "10007:8080" ];
        networks = ["lubelogger"];
        hostname = "lubelogger";

        volumes = [
            "lubelogger_data:/App/data"
            "lubelogger_keys:/root/.aspnet/DataProtection-Keys"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/hargata/lubelog/releases";
            "traefik.enable" = "true";
            "traefik.http.services.lubelogger.loadbalancer.server.port" = "10007";
            "traefik.http.routers.lubelogger.rule" = "Host(`vehicles.azollerstuff.xyz`)";
            "traefik.http.routers.lubelogger.entrypoints" = "https";
            "traefik.http.routers.lubelogger.tls" = "true";
            "traefik.http.routers.lubelogger.tls.certresolver" = "le";
            "traefik.http.routers.lubelogger.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.lubelogger.middlewares" = "secheader@file";
        };
    };
}

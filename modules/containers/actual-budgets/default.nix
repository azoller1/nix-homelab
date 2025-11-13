{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."actual-budgets" = {

        image = "ghcr.io/actualbudget/actual-server:25.11.0";
        autoStart = true;
        ports = [ "10000:5006" ];
        networks = ["actual-budgets"];
        hostname = "actual-budgets";

        volumes = [
            "actual-budgets_data:/data"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/actualbudget/actual/releases";
            "traefik.enable" = "true";
            "traefik.http.services.actual-budgets.loadbalancer.server.port" = "10000";
            "traefik.http.routers.actual-budgets.rule" = "Host(`money.azollerstuff.xyz`)";
            "traefik.http.routers.actual-budgets.entrypoints" = "https";
            "traefik.http.routers.actual-budgets.tls" = "true";
            "traefik.http.routers.actual-budgets.tls.certresolver" = "le";
            "traefik.http.routers.actual-budgets.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.actual-budgets.middlewares" = "secheader@file";
        };
    };
}

{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."sftpgo" = {

        image = "ghcr.io/drakkan/sftpgo:v2.7-distroless-slim";
        ports = ["2022:2022"];
        networks = ["sftpgo"];
        hostname = "sftpgo";

        volumes = [
            "sftpgo_data:/srv/sftpgo"
            "sftpgo_extra:/var/lib/sftpgo"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.sftpgo.loadbalancer.server.port" = "8080";
            "traefik.http.routers.sftpgo.service" = "sftpgo";
            "traefik.http.routers.sftpgo.rule" = "Host(`files.zollerlab.com`)";
            "traefik.http.routers.sftpgo.entrypoints" = "https";
            "traefik.http.routers.sftpgo.tls" = "true";
            "traefik.http.routers.sftpgo.tls.certresolver" = "le";
            "traefik.http.routers.sftpgo.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.sftpgo.middlewares" = "secheader@file";
        };
    };
}

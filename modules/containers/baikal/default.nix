{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."baikal-dav" = {

        image = "docker.io/ckulka/baikal:0.10.1-nginx-php8.2";
        #autoStart = true;
        ports = [ "10001:80" ];
        networks = ["baikal-dav"];
        hostname = "baikal-dav";

        volumes = [
            "baikal-dav_config:/var/www/baikal/config"
            "baikal-dav_data:/var/www/baikal/Specific"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+-nginx-php8.2$";
            "wud.link.template" = "https://github.com/ckulka/baikal-docker/releases";
            "traefik.enable" = "true";
            "traefik.http.services.baikal-dav.loadbalancer.server.port" = "10001";
            "traefik.http.routers.baikal-dav.rule" = "Host(`dav.azollerstuff.xyz`)";
            "traefik.http.routers.baikal-dav.entrypoints" = "https";
            "traefik.http.routers.baikal-dav.tls" = "true";
            "traefik.http.routers.baikal-dav.tls.certresolver" = "le";
            "traefik.http.routers.baikal-dav.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.baikal-dav.middlewares" = "secheader@file";
        };
    };
}
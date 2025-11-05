{ config, lib, pkgs, ...}:

{
    systemd.services."docker-beszel" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-beszel.service"];
        requires = ["docker-network-beszel.service"];
        partOf = ["docker-beszel-base.target"];
        wantedBy = ["docker-beszel-base.target"];
    };

    systemd.services."docker-network-beszel" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f beszel";
        };

        script = ''
            docker network inspect beszel || docker network create beszel --ipv6
        '';

        partOf = [ "docker-beszel-base.target" ];
        wantedBy = [ "docker-beszel-base.target" ];
    };

    systemd.targets."docker-beszel-base" = {

        unitConfig = {
            Description = "beszel base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."beszel" = {

        image = "ghcr.io/henrygd/beszel/beszel:0.14.0";
        #autoStart = true;
        networks = ["beszel"];
        hostname = "beszel";

        volumes = [
            "beszel_data:/beszel_data"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/henrygd/beszel/releases";
            "traefik.enable" = "true";
            "traefik.http.services.beszel.loadbalancer.server.port" = "8090";
            "traefik.http.routers.beszel.rule" = "Host(`stats.azollerstuff.xyz`)";
            "traefik.http.routers.beszel.entrypoints" = "https";
            "traefik.http.routers.beszel.tls" = "true";
            "traefik.http.routers.beszel.tls.certresolver" = "le";
            "traefik.http.routers.beszel.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.beszel.middlewares" = "secheader@file";
        };
    };
}
{ config, lib, pkgs, ...}:

{
    systemd.services."docker-adventurelog-web" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-adventurelog.service"];
        requires = ["docker-network-adventurelog.service"];
        partOf = ["docker-adventurelog-base.target"];
        wantedBy = ["docker-adventurelog-base.target"];
    };

    systemd.services."docker-adventurelog-server" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-adventurelog.service"];
        requires = ["docker-network-adventurelog.service"];
        partOf = ["docker-adventurelog-base.target"];
        wantedBy = ["docker-adventurelog-base.target"];
    };

    systemd.services."docker-network-adventurelog" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f adventurelog";
        };

        script = ''
            docker network inspect adventurelog || docker network create adventurelog --ipv6
        '';

        partOf = [ "docker-adventurelog-base.target" ];
        wantedBy = [ "docker-adventurelog-base.target" ];
    };

    systemd.targets."docker-adventurelog-base" = {

        unitConfig = {
            Description = "adventurelog base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."adventurelog-server" = {

        image = "ghcr.io/seanmorley15/adventurelog-backend:v0.11.0";
        #autoStart = true;
        ports = [ "10009:80" ];
        networks = ["adventurelog"];
        hostname = "adventurelog-server";

        volumes = [
            "adventurelog_media:/code/media/"
        ];

        environmentFiles = [
            "/home/azoller/containers/advlog/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/seanmorley15/AdventureLog/releases";
            "traefik.enable" = "true";
            "traefik.http.services.advlog-server.loadbalancer.server.port" = "10009";
            "traefik.http.routers.advlog-server.rule" = "Host(`adventure-server.azollerstuff.xyz`)";
            "traefik.http.routers.advlog-server.entrypoints" = "https";
            "traefik.http.routers.advlog-server.tls" = "true";
            "traefik.http.routers.advlog-server.tls.certresolver" = "le";
            "traefik.http.routers.advlog-server.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.advlog-server.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."adventurelog-web" = {

        image = "ghcr.io/seanmorley15/adventurelog-frontend:v0.11.0";
        #autoStart = true;
        ports = [ "10008:3000" ];
        networks = ["adventurelog"];
        hostname = "adventurelog-web";

        environmentFiles = [
            "/home/azoller/containers/advlog/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/seanmorley15/AdventureLog/releases";
            "traefik.enable" = "true";
            "traefik.http.services.advlog.loadbalancer.server.port" = "10008";
            "traefik.http.routers.advlog.rule" = "Host(`adventure.azollerstuff.xyz`)";
            "traefik.http.routers.advlog.entrypoints" = "https";
            "traefik.http.routers.advlog.tls" = "true";
            "traefik.http.routers.advlog.tls.certresolver" = "le";
            "traefik.http.routers.advlog.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.advlog.middlewares" = "secheader@file";
        };
    };
}
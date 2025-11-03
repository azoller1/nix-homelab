{ config, lib, pkgs, ...}:

{
    systemd.services."docker-jotty" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-jotty.service"];
        requires = ["docker-network-jotty.service"];
        partOf = ["docker-jotty-base.target"];
        wantedBy = ["docker-jotty-base.target"];
    };

    systemd.services."docker-network-jotty" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f jotty";
        };

        script = ''
            docker network inspect jotty || docker network create jotty --ipv6
        '';

        partOf = [ "docker-jotty-base.target" ];
        wantedBy = [ "docker-jotty-base.target" ];
    };

    systemd.targets."docker-jotty-base" = {

        unitConfig = {
            Description = "jotty base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."jotty" = {

        image = "ghcr.io/fccview/jotty:1.8.0";
        #autoStart = true;
        ports = [ "10006:3000" ];
        networks = ["jotty"];
        hostname = "jotty";

        volumes = [
            "data:/app/data:rw"
            "config:/app/config:ro"
            "cache:/app/.next/cache:rw"
        ];

        environment = {
            NODE_ENV = "production";
        };

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^\d+\.\d+\.\d+$$";
            "wud.link.template" = "https://github.com/fccview/jotty/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.marknote.loadbalancer.server.port" = "10006";
            "traefik.http.routers.marknote.rule" = "Host(`mnotes.azollerstuff.xyz`)";
            "traefik.http.routers.marknote.entrypoints" = "https";
            "traefik.http.routers.marknote.tls" = "true";
            "traefik.http.routers.marknote.tls.certresolver" = "le";
            "traefik.http.routers.marknote.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.marknote.middlewares" = "secheader@file";
        };
    };
}
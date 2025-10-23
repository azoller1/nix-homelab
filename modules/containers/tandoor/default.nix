{ config, lib, pkgs, ...}:

{
    systemd.services."docker-tandoor" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-tandoor.service"];
        requires = ["docker-network-tandoor.service"];
        partOf = ["docker-tandoor-base.target"];
        wantedBy = ["docker-tandoor-base.target"];
    };

    systemd.services."docker-network-tandoor" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f tandoor";
        };

        script = ''
            docker network inspect tandoor || docker network create tandoor --ipv6
        '';

        partOf = [ "docker-tandoor-base.target" ];
        wantedBy = [ "docker-tandoor-base.target" ];
    };

    systemd.targets."docker-tandoor-base" = {

        unitConfig = {
            Description = "tandoor base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."tandoor" = {

        image = "ghcr.io/tandoorrecipes/recipes:2.3.3";
        #autoStart = true;
        ports = [ "10010:80" ];
        networks = ["tandoor"];
        hostname = "tandoor";

        volumes = [
            "tandoor_staticfiles:/opt/recipes/staticfiles"
            "tandoor_mediafiles:/opt/recipes/mediafiles"
        ];

        environmentFiles = [
            "/home/azoller/containers/tandoor/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.tandoor.loadbalancer.server.port" = "10010";
            "traefik.http.routers.tandoor.rule" = "Host(`recipes.azollerstuff.xyz`)";
            "traefik.http.routers.tandoor.entrypoints" = "https";
            "traefik.http.routers.tandoor.tls" = "true";
            "traefik.http.routers.tandoor.tls.certresolver" = "le";
            "traefik.http.routers.tandoor.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.tandoor.middlewares" = "secheader@file";
        };
    };
}
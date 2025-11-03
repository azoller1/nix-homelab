{ config, lib, pkgs, ...}:

{
    systemd.services."docker-scrobbler" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-scrobbler.service"];
        requires = ["docker-network-scrobbler.service"];
        partOf = ["docker-scrobbler-base.target"];
        wantedBy = ["docker-scrobbler-base.target"];
    };

    systemd.services."docker-network-scrobbler" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f scrobbler";
        };

        script = ''
            docker network inspect scrobbler || docker network create scrobbler --ipv6
        '';

        partOf = [ "docker-scrobbler-base.target" ];
        wantedBy = [ "docker-scrobbler-base.target" ];
    };

    systemd.targets."docker-scrobbler-base" = {

        unitConfig = {
            Description = "scrobbler base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."scrobbler" = {

        image = "ghcr.io/foxxmd/multi-scrobbler:0.10.0";
        ports = [ "10003:9078" ];
        networks = ["scrobbler"];
        hostname = "scrobbler";

        volumes = [
            "scrobbler_config:/config"
        ];

        environmentFiles = [
            /home/azoller/containers/scrobbler/env
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
            BASE_URL = "https://scrobbler.azollerstuff.xyz";
        };

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "wud.watch" = "true";
            "wud.tag.include" = "^\d+\.\d+\.\d+$$";
            "wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.scrobbler.loadbalancer.server.port" = "10003";
            "traefik.http.routers.scrobbler.rule" = "Host(`scrobbler.azollerstuff.xyz`)";
            "traefik.http.routers.scrobbler.entrypoints" = "https";
            "traefik.http.routers.scrobbler.tls" = "true";
            "traefik.http.routers.scrobbler.tls.certresolver" = "le";
            "traefik.http.routers.scrobbler.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.scrobbler.middlewares" = "secheader@file";
        };
    };
}
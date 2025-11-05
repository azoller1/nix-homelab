{ config, lib, pkgs, ...}:

{
    systemd.services."docker-pocket-id" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-pocket-id.service"];
        requires = ["docker-network-pocket-id.service"];
        partOf = ["docker-pocket-id-base.target"];
        wantedBy = ["docker-pocket-id-base.target"];
    };

    systemd.services."docker-network-pocket-id" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f pocket-id";
        };

        script = ''
            docker network inspect pocket-id || docker network create pocket-id --ipv6
        '';

        partOf = [ "docker-pocket-id-base.target" ];
        wantedBy = [ "docker-pocket-id-base.target" ];
    };

    systemd.targets."docker-pocket-id-base" = {

        unitConfig = {
            Description = "pocket-id base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."pocket-id" = {

        image = "ghcr.io/pocket-id/pocket-id:v1.13.1";
        networks = ["pocket-id"];
        #autoStart = true;
        hostname = "pocket-id";

        volumes = [
            "pocket-id_data:/app/data"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.pocket-id
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";;
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.pocket-id.loadbalancer.server.port" = "1411";
            "traefik.http.routers.pocket-id.rule" = "Host(`auth.azollerstuff.xyz`)";
            "traefik.http.routers.pocket-id.entrypoints" = "https";
            "traefik.http.routers.pocket-id.tls" = "true";
            "traefik.http.routers.pocket-id.tls.certresolver" = "le";
            "traefik.http.routers.pocket-id.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.pocket-id.middlewares" = "secheader@file";
        };
    };
}
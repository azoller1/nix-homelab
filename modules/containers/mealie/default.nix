{ config, lib, pkgs, ...}:

{
    systemd.services."docker-mealie" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-mealie.service"];
        requires = ["docker-network-mealie.service"];
        partOf = ["docker-mealie-base.target"];
        wantedBy = ["docker-mealie-base.target"];
    };

    systemd.services."docker-network-mealie" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f mealie";
        };

        script = ''
            docker network inspect mealie || docker network create mealie --ipv6
        '';

        partOf = [ "docker-mealie-base.target" ];
        wantedBy = [ "docker-mealie-base.target" ];
    };

    systemd.targets."docker-mealie-base" = {

        unitConfig = {
            Description = "mealie base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."mealie" = {

        image = "ghcr.io/mealie-recipes/mealie:v3.3.2";
        ports = [ "10011:9000" ];
        networks = ["mealie"];
        hostname = "mealie";

        volumes = [
            "mealie_data:/app/data/"
        ];

        environment = {
            ALLOW_SIGNUP = "false";
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
            BASE_URL = "https://recipes.azollerstuff.xyz";
        };

        extraOptions = [
            "--memory=1024m"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.mealie.loadbalancer.server.port" = "10011";
            "traefik.http.routers.mealie.rule" = "Host(`recipes.azollerstuff.xyz`)";
            "traefik.http.routers.mealie.entrypoints" = "https";
            "traefik.http.routers.mealie.tls" = "true";
            "traefik.http.routers.mealie.tls.certresolver" = "le";
            "traefik.http.routers.mealie.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.mealie.middlewares" = "secheader@file";
        };
    };
}
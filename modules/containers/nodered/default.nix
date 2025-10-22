{ config, lib, pkgs, ...}:

{
    systemd.services."docker-nodered" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-nodered.service"];
        requires = ["docker-network-nodered.service"];
        partOf = ["docker-nodered-base.target"];
        wantedBy = ["docker-nodered-base.target"];
    };

    systemd.services."docker-network-nodered" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f nodered";
        };

        script = ''
            docker network inspect nodered || docker network create nodered --ipv6
        '';

        partOf = [ "docker-nodered-base.target" ];
        wantedBy = [ "docker-nodered-base.target" ];
    };

    systemd.targets."docker-nodered-base" = {

        unitConfig = {
            Description = "nodered base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."nodered" = {

        image = "docker.io/nodered/node-red:4.1.0";
        #autoStart = true;
        ports = [ "10001:1880" ];
        networks = ["nodered"];
        hostname = "nodered";

        environment = {
            TZ = "America/Chicago";
        };

        volumes = [
            "nodered_data:/data"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.nodered.loadbalancer.server.port" = "10001";
            "traefik.http.routers.nodered.rule" = "Host(`node-red.azollerstuff.xyz`)";
            "traefik.http.routers.nodered.entrypoints" = "https";
            "traefik.http.routers.nodered.tls" = "true";
            "traefik.http.routers.nodered.tls.certresolver" = "le";
            "traefik.http.routers.nodered.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.nodered.middlewares" = "secheader@file,oidc-auth-nodered@file";
        };
    };
}
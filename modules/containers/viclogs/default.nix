{ config, lib, pkgs, ...}:

{
    systemd.services."docker-viclogs" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-viclogs.service"];
        requires = ["docker-network-viclogs.service"];
        partOf = ["docker-viclogs-base.target"];
        wantedBy = ["docker-viclogs-base.target"];
    };

    systemd.services."docker-network-viclogs" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f viclogs";
        };

        script = ''
            docker network inspect viclogs || docker network create viclogs --ipv6
        '';

        partOf = [ "docker-viclogs-base.target" ];
        wantedBy = [ "docker-viclogs-base.target" ];
    };

    systemd.targets."docker-viclogs-base" = {

        unitConfig = {
            Description = "viclogs base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."viclogs" = {

        image = "docker.io/victoriametrics/victoria-logs:v1.36.1";
        networks = ["viclogs"];
        #autoStart = true;
        hostname = "viclogs";

        volumes = [
            "viclogs_data:/victoria-logs-data"
        ];

        cmd = [
            "-storageDataPath=victoria-logs-data"
        ];

        labels = {
            "diun.enable" = "true";
            "diun.include_tags" = "^\d+\.\d+\..*$";
            "traefik.enable" = "true";
            "traefik.http.services.viclogs.loadbalancer.server.port" = "9428";
            "traefik.http.routers.viclogs.rule" = "Host(`viclogs.azollerstuff.xyz`)";
            "traefik.http.routers.viclogs.entrypoints" = "https";
            "traefik.http.routers.viclogs.tls" = "true";
            "traefik.http.routers.viclogs.tls.certresolver" = "le";
            "traefik.http.routers.viclogs.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.viclogs.middlewares" = "secheader@file";
        };
    };
}
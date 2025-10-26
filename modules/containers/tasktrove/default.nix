{ config, lib, pkgs, ...}:

{
    systemd.services."docker-tasktrove" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-tasktrove.service"];
        requires = ["docker-network-tasktrove.service"];
        partOf = ["docker-tasktrove-base.target"];
        wantedBy = ["docker-tasktrove-base.target"];
    };

    systemd.services."docker-network-tasktrove" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f tasktrove";
        };

        script = ''
            docker network inspect tasktrove || docker network create tasktrove --ipv6
        '';

        partOf = [ "docker-tasktrove-base.target" ];
        wantedBy = [ "docker-tasktrove-base.target" ];
    };

    systemd.targets."docker-tasktrove-base" = {

        unitConfig = {
            Description = "tasktrove base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."tasktrove" = {

        image = "ghcr.io/dohsimpson/tasktrove:v0.8.0";
        #autoStart = true;
        ports = [ "10012:3000" ];
        networks = ["tasktrove"];
        hostname = "tasktrove";

        volumes = [
            "tasktrove_data:/app/data"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.tasktrove.loadbalancer.server.port" = "10012";
            "traefik.http.routers.tasktrove.rule" = "Host(`tasks.azollerstuff.xyz`)";
            "traefik.http.routers.tasktrove.entrypoints" = "https";
            "traefik.http.routers.tasktrove.tls" = "true";
            "traefik.http.routers.tasktrove.tls.certresolver" = "le";
            "traefik.http.routers.tasktrove.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.tasktrove.middlewares" = "secheader@file";
        };
    };
}
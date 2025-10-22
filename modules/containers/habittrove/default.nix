{ config, lib, pkgs, ...}:

{
    systemd.services."docker-habittrove" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-habittrove.service"];
        requires = ["docker-network-habittrove.service"];
        partOf = ["docker-habittrove-base.target"];
        wantedBy = ["docker-habittrove-base.target"];
    };

    systemd.services."docker-network-habittrove" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f habittrove";
        };

        script = ''
            docker network inspect habittrove || docker network create habittrove --ipv6
        '';

        partOf = [ "docker-habittrove-base.target" ];
        wantedBy = [ "docker-habittrove-base.target" ];
    };

    systemd.targets."docker-habittrove-base" = {

        unitConfig = {
            Description = "habittrove base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."habittrove" = {

        image = "docker.io/dohsimpson/habittrove:v0.2.29";
        #autoStart = true;
        ports = [ "10002:3000" ];
        networks = ["habittrove"];
        hostname = "habittrove";

        volumes = [
            "habittrove_backups:/app/backups"
            "habittrove_data:/app/data"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/node1/.env.secret.habittrove
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.habittrove.loadbalancer.server.port" = "10002";
            "traefik.http.routers.habittrove.rule" = "Host(`habits.azollerstuff.xyz`)";
            "traefik.http.routers.habittrove.entrypoints" = "https";
            "traefik.http.routers.habittrove.tls" = "true";
            "traefik.http.routers.habittrove.tls.certresolver" = "le";
            "traefik.http.routers.habittrove.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.habittrove.middlewares" = "secheader@file";
        };
    };
}
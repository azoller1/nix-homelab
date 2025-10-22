{ config, lib, pkgs, ...}:

{
    systemd.services."docker-romm" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-romm.service"];
        requires = ["docker-network-romm.service"];
        partOf = ["docker-romm-base.target"];
        wantedBy = ["docker-romm-base.target"];
    };

    systemd.services."docker-network-romm" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f romm";
        };

        script = ''
            docker network inspect romm || docker network create romm --ipv6
        '';

        partOf = [ "docker-romm-base.target" ];
        wantedBy = [ "docker-romm-base.target" ];
    };

    systemd.targets."docker-romm-base" = {

        unitConfig = {
            Description = "romm base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."romm" = {

        image = "ghcr.io/rommapp/romm:4.3.2";
        #autoStart = true;
        networks = ["romm"];
        hostname = "romm";

        volumes = [
            "romm_data:/romm/resources"
            "romm_redis_data:/redis-data"
            "/mnt/data/romm/library:/romm/library"
            "/mnt/data/romm/assets:/romm/assets"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.romm
        ];

        labels = {
            "diun.enable" = "true";
            "traefik.enable" = "true";
            "traefik.http.services.romm.loadbalancer.server.port" = "8080";
            "traefik.http.routers.romm.rule" = "Host(`romm.azollerstuff.xyz`)";
            "traefik.http.routers.romm.entrypoints" = "https";
            "traefik.http.routers.romm.tls" = "true";
            "traefik.http.routers.romm.tls.certresolver" = "le";
            "traefik.http.routers.romm.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.romm.middlewares" = "secheader@file";
        };
    };
}

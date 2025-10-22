{ config, lib, pkgs, ...}:

{
    systemd.services."docker-apprise" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-apprise.service"];
        requires = ["docker-network-apprise.service"];
        partOf = ["docker-apprise-base.target"];
        wantedBy = ["docker-apprise-base.target"];
    };

    systemd.services."docker-network-apprise" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f apprise";
        };

        script = ''
            docker network inspect apprise || docker network create apprise --ipv6
        '';

        partOf = [ "docker-apprise-base.target" ];
        wantedBy = [ "docker-apprise-base.target" ];
    };

    systemd.targets."docker-apprise-base" = {

        unitConfig = {
            Description = "Apprise API Base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."apprise" = {

        image = "ghcr.io/caronc/apprise:1.2.1";
        #autoStart = true;
        ports = [ "10000:8000" ];
        networks = ["apprise"];
        hostname = "apprise";

        volumes = [
            "apprise_config:/config"
            "apprise_plugin:/plugin"
            "apprise_attach:/attach"
            "apprise_data:/config/store"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/node1/.env.secret.apprise
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.apprise.loadbalancer.server.port" = "10000";
            "traefik.http.routers.apprise.rule" = "Host(`apprise.azollerstuff.xyz`)";
            "traefik.http.routers.apprise.entrypoints" = "https";
            "traefik.http.routers.apprise.tls" = "true";
            "traefik.http.routers.apprise.tls.certresolver" = "le";
            "traefik.http.routers.apprise.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.apprise.middlewares" = "secheader@file";
        };
    };
}
{ config, lib, pkgs, ...}:

{
    systemd.services."docker-vicmetrics" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-vicmetrics.service"];
        requires = ["docker-network-vicmetrics.service"];
        partOf = ["docker-vicmetrics-base.target"];
        wantedBy = ["docker-vicmetrics-base.target"];
    };

    systemd.services."docker-network-vicmetrics" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f vicmetrics";
        };

        script = ''
            docker network inspect vicmetrics || docker network create vicmetrics --ipv6
        '';

        partOf = [ "docker-vicmetrics-base.target" ];
        wantedBy = [ "docker-vicmetrics-base.target" ];
    };

    systemd.targets."docker-vicmetrics-base" = {

        unitConfig = {
            Description = "vicmetrics base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."vicmetrics" = {

        image = "docker.io/victoriametrics/victoria-metrics:v1.128.0";
        networks = ["vicmetrics"];
        #autoStart = true;
        hostname = "vicmetrics";

        volumes = [
            "vicmetrics_data:/victoria-metrics-data"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.vicmetrics.loadbalancer.server.port" = "8428";
            "traefik.http.routers.vicmetrics.rule" = "Host(`vicmetrics.azollerstuff.xyz`)";
            "traefik.http.routers.vicmetrics.entrypoints" = "https";
            "traefik.http.routers.vicmetrics.tls" = "true";
            "traefik.http.routers.vicmetrics.tls.certresolver" = "le";
            "traefik.http.routers.vicmetrics.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.vicmetrics.middlewares" = "secheader@file";
        };
    };
}
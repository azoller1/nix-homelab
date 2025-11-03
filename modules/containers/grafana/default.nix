{ config, lib, pkgs, ...}:

{
    systemd.services."docker-grafana" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-grafana.service"];
        requires = ["docker-network-grafana.service"];
        partOf = ["docker-grafana-base.target"];
        wantedBy = ["docker-grafana-base.target"];
    };

    systemd.services."docker-network-grafana" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f grafana";
        };

        script = ''
            docker network inspect grafana || docker network create grafana --ipv6
        '';

        partOf = [ "docker-grafana-base.target" ];
        wantedBy = [ "docker-grafana-base.target" ];
    };

    systemd.targets."docker-grafana-base" = {

        unitConfig = {
            Description = "grafana base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."grafana" = {

        image = "docker.io/grafana/grafana:12.2";
        #autoStart = true;
        networks = ["grafana"];
        hostname = "grafana";

        environment = {
            GF_SERVER_ROOT_URL = "https://grafana.azollerstuff.xyz";
            GF_PLUGINS_PREINSTALL = "grafana-clock-panel";
        };

        volumes = [
            "grafana_data:/var/lib/grafana"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.grafana.loadbalancer.server.port" = "3000";
            "traefik.http.routers.grafana.rule" = "Host(`grafana.azollerstuff.xyz`)";
            "traefik.http.routers.grafana.entrypoints" = "https";
            "traefik.http.routers.grafana.tls" = "true";
            "traefik.http.routers.grafana.tls.certresolver" = "le";
            "traefik.http.routers.grafana.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.grafana.middlewares" = "secheader@file";
        };
    };
}
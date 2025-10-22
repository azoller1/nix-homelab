{ config, lib, pkgs, ...}:

{
    systemd.services."docker-actual-budgets" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-actual-budgets.service"];
        requires = ["docker-network-actual-budgets.service"];
        partOf = ["docker-actual-budgets-base.target"];
        wantedBy = ["docker-actual-budgets-base.target"];
    };

    systemd.services."docker-network-actual-budgets" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f actual-budgets";
        };

        script = ''
            docker network inspect actual-budgets || docker network create actual-budgets --ipv6
        '';

        partOf = [ "docker-actual-budgets-base.target" ];
        wantedBy = [ "docker-actual-budgets-base.target" ];
    };

    systemd.targets."docker-actual-budgets-base" = {

        unitConfig = {
            Description = "Actual Budgets Base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."actual-budgets" = {

        image = "ghcr.io/actualbudget/actual-server:25.10.0";
        #autoStart = true;
        ports = [ "10000:5006" ];
        networks = ["actual-budgets"];
        hostname = "actual-budgets";

        volumes = [
            "actual-budgets_data:/data"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.actual-budgets.loadbalancer.server.port" = "10000";
            "traefik.http.routers.actual-budgets.rule" = "Host(`money.azollerstuff.xyz`)";
            "traefik.http.routers.actual-budgets.entrypoints" = "https";
            "traefik.http.routers.actual-budgets.tls" = "true";
            "traefik.http.routers.actual-budgets.tls.certresolver" = "le";
            "traefik.http.routers.actual-budgets.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.actual-budgets.middlewares" = "secheader@file";
        };
    };
}
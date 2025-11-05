{ config, lib, pkgs, ...}:

{
    systemd.services."docker-prom" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-prom.service"];
        requires = ["docker-network-prom.service"];
        partOf = ["docker-prom-base.target"];
        wantedBy = ["docker-prom-base.target"];
    };

    systemd.services."docker-network-prom" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f prom";
        };

        script = ''
            docker network inspect prom || docker network create prom --ipv6
        '';

        partOf = [ "docker-prom-base.target" ];
        wantedBy = [ "docker-prom-base.target" ];
    };

    systemd.targets."docker-prom-base" = {

        unitConfig = {
            Description = "prom base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."prom" = {

        image = "docker.io/prom/prometheus:v3.7.1";
        networks = ["prom"];
        #autoStart = true;
        hostname = "prom";

        volumes = [
            "prom_data:/prometheus"
            "/home/azoller/nix-homelab/hosts/main-server/.env.secret.promconf:/etc/prometheus/prometheus.yml"
        ];

        cmd = [
            "--web.enable-remote-write-receiver"
            "--config.file=/etc/prometheus/prometheus.yml"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.prom.loadbalancer.server.port" = "9090";
            "traefik.http.routers.prom.rule" = "Host(`prom.azollerstuff.xyz`)";
            "traefik.http.routers.prom.entrypoints" = "https";
            "traefik.http.routers.prom.tls" = "true";
            "traefik.http.routers.prom.tls.certresolver" = "le";
            "traefik.http.routers.prom.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.prom.middlewares" = "secheader@file";
        };
    };
}
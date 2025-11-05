{ config, lib, pkgs, ...}:

{
    systemd.services."docker-yamtrack" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-yamtrack.service"];
        requires = ["docker-network-yamtrack.service"];
        partOf = ["docker-yamtrack-base.target"];
        wantedBy = ["docker-yamtrack-base.target"];
    };

    systemd.services."docker-yamtrack-valkey" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-yamtrack.service"];
        requires = ["docker-network-yamtrack.service"];
        partOf = ["docker-yamtrack-base.target"];
        wantedBy = ["docker-yamtrack-base.target"];
    };

    systemd.services."docker-network-yamtrack" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f yamtrack";
        };

        script = ''
            docker network inspect yamtrack || docker network create yamtrack --ipv6
        '';

        partOf = [ "docker-yamtrack-base.target" ];
        wantedBy = [ "docker-yamtrack-base.target" ];
    };

    systemd.targets."docker-yamtrack-base" = {

        unitConfig = {
            Description = "yamtrack base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."yamtrack-valkey" = {

        image = "docker.io/valkey/valkey:8-bookworm";
        networks = ["yamtrack"];
        hostname = "yamtrack-valkey";

        volumes = [
            "yamtrack_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel warning"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."yamtrack" = {

        image = "ghcr.io/fuzzygrim/yamtrack:0.24.7";
        ports = [ "10013:8000" ];
        networks = ["yamtrack"];
        hostname = "yamtrack";

        volumes = [
            "yamtrack_data:/yamtrack/db"
        ];

        environment = {
            TZ = "America/Chicago";
            REDIS_URL = "redis://yamtrack-valkey:6379";
        };

        environmentFiles = [
            "/home/azoller/containers/yamtrack/env"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/dani-garcia/vaultwarden/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.yamtrack.loadbalancer.server.port" = "10013";
            "traefik.http.routers.yamtrack.rule" = "Host(`yamtrack.azollerstuff.xyz`)";
            "traefik.http.routers.yamtrack.entrypoints" = "https";
            "traefik.http.routers.yamtrack.tls" = "true";
            "traefik.http.routers.yamtrack.tls.certresolver" = "le";
            "traefik.http.routers.yamtrack.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.yamtrack.middlewares" = "secheader@file";
        };
    };
}
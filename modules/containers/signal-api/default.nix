{ config, lib, pkgs, ...}:

{
    systemd.services."docker-signal-api" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-signal-api.service"];
        requires = ["docker-network-signal-api.service"];
        partOf = ["docker-signal-api-base.target"];
        wantedBy = ["docker-signal-api-base.target"];
    };

    systemd.services."docker-network-signal-api" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f signal-api";
        };

        script = ''
            docker network inspect signal-api || docker network create signal-api --ipv6
        '';

        partOf = [ "docker-signal-api-base.target" ];
        wantedBy = [ "docker-signal-api-base.target" ];
    };

    systemd.targets."docker-signal-api-base" = {

        unitConfig = {
            Description = "signal-api base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."signal-api" = {

        image = "docker.io/bbernhard/signal-cli-rest-api:0.95";
        networks = ["signal-api"];
        #autoStart = true;
        hostname = "signal-api";

        volumes = [
            "signal-api_data:/home/.local/share/signal-cli"
        ];

        environment = {
            MODE = "json-rpc";
        };

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^\d+\.\d+$$";
            #"wud.link.template" = "https://github.com/FoxxMD/multi-scrobbler/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.signal-api.loadbalancer.server.port" = "8080";
            "traefik.http.routers.signal-api.rule" = "Host(`signal-api.azollerstuff.xyz`)";
            "traefik.http.routers.signal-api.entrypoints" = "https";
            "traefik.http.routers.signal-api.tls" = "true";
            "traefik.http.routers.signal-api.tls.certresolver" = "le";
            "traefik.http.routers.signal-api.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.signal-api.middlewares" = "secheader@file";
        };
    };
}
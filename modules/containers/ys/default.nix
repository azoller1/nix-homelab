{ config, lib, pkgs, ...}:

{
    systemd.services."docker-ys-client" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-ys.service"];
        requires = ["docker-network-ys.service"];
        partOf = ["docker-ys-base.target"];
        wantedBy = ["docker-ys-base.target"];
    };

    systemd.services."docker-ys-server" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-ys.service"];
        requires = ["docker-network-ys.service"];
        partOf = ["docker-ys-base.target"];
        wantedBy = ["docker-ys-base.target"];
    };

    systemd.services."docker-network-ys" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f ys-client";
        };

        script = ''
            docker network inspect ys || docker network create ys --ipv6
        '';

        partOf = [ "docker-ys-base.target" ];
        wantedBy = [ "docker-ys-base.target" ];
    };

    systemd.targets."docker-ys-base" = {

        unitConfig = {
            Description = "yourspotify base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."ys-client" = {

        image = "ghcr.io/yooooomi/your_spotify_client:1.14.0";
        #autoStart = true;
        ports = [ "10005:3000" ];
        networks = ["ys"];
        hostname = "ys-client";

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/node1/.env.secret.ys
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/dani-garcia/vaultwarden/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.ys-client.loadbalancer.server.port" = "10005";
            "traefik.http.routers.ys-client.rule" = "Host(`spotifystats.azollerstuff.xyz`)";
            "traefik.http.routers.ys-client.entrypoints" = "https";
            "traefik.http.routers.ys-client.tls" = "true";
            "traefik.http.routers.ys-client.tls.certresolver" = "le";
            "traefik.http.routers.ys-client.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.ys-client.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."ys-server" = {

        image = "ghcr.io/yooooomi/your_spotify_server:1.14.0";
        #autoStart = true;
        ports = [ "10004:8080" ];
        networks = ["ys"];
        hostname = "ys-server";

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/node1/.env.secret.ys
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/dani-garcia/vaultwarden/releases/tag/$${major}.$${minor}.$${patch}";
            "traefik.enable" = "true";
            "traefik.http.services.ys-server.loadbalancer.server.port" = "10004";
            "traefik.http.routers.ys-server.rule" = "Host(`ssapi.azollerstuff.xyz`)";
            "traefik.http.routers.ys-server.entrypoints" = "https";
            "traefik.http.routers.ys-server.tls" = "true";
            "traefik.http.routers.ys-server.tls.certresolver" = "le";
            "traefik.http.routers.ys-server.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.ys-server.middlewares" = "secheader@file";
        };
    };
}
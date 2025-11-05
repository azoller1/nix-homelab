{ config, lib, pkgs, ...}:

{
    systemd.services."docker-forgejo" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-forgejo.service"];
        requires = ["docker-network-forgejo.service"];
        partOf = ["docker-forgejo-base.target"];
        wantedBy = ["docker-forgejo-base.target"];
    };

    systemd.services."docker-network-forgejo" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f forgejo";
        };

        script = ''
            docker network inspect forgejo || docker network create forgejo --ipv6
        '';

        partOf = [ "docker-forgejo-base.target" ];
        wantedBy = [ "docker-forgejo-base.target" ];
    };

    systemd.targets."docker-forgejo-base" = {

        unitConfig = {
            Description = "forgejo base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."forgejo" = {

        image = "codeberg.org/forgejo/forgejo:13.0.1-rootless";
        #autoStart = true;
        networks = ["forgejo"];
        hostname = "forgejo";

        environment = {
            USER_UID = "1000";
            USER_GID = "100";
        };

        volumes = [
            "forgejo:/var/lib/gitea"
            "/home/azoller/nix-homelab/hosts/main-server/.env.secret.forgejoconf:/var/lib/gitea/custom/conf/app.ini"
            "/etc/timezone:/etc/timezone:ro"
            "/etc/localtime:/etc/localtime:ro"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+-rootless$";
            "wud.link.template" = "https://codeberg.org/forgejo/forgejo/releases/tag/v${major}.${minor}.${patch}";
            "traefik.enable" = "true";
            "traefik.http.routers.forgejo.service" = "forgejo";
            "traefik.http.services.forgejo.loadbalancer.server.port" = "3000";
            "traefik.http.routers.forgejo.rule" = "Host(`git.azollerstuff.xyz`)";
            "traefik.http.routers.forgejo.entrypoints" = "https";
            "traefik.http.routers.forgejo.tls" = "true";
            "traefik.http.routers.forgejo.tls.certresolver" = "le";
            "traefik.http.routers.forgejo.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.forgejo.middlewares" = "secheader@file";
            "traefik.tcp.routers.forgejoSSH.service" = "forgejoSSH";
            "traefik.tcp.services.forgejoSSH.loadbalancer.server.port" = "2222";
            "traefik.tcp.routers.forgejoSSH.rule" = "HostSNI(`git.azollerstuff.xyz`)";
            "traefik.tcp.routers.forgejoSSH.entrypoints" = "https";
            "traefik.tcp.routers.forgejoSSH.tls" = "true";
            "traefik.tcp.routers.forgejoSSH.tls.certresolver" = "le";
            "traefik.tcp.routers.forgejoSSH.tls.domains[0].main" = "*.azollerstuff.xyz";
        };
    };
}
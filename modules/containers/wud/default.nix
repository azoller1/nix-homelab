{ config, lib, pkgs, ...}:

{

    systemd.services."docker-wud" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wud.service"];
        requires = ["docker-network-wud.service"];
        partOf = ["docker-wud-base.target"];
        wantedBy = ["docker-wud-base.target"];
    };

    systemd.services."docker-socket-proxy-wud" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-wud.service"];
        requires = ["docker-network-wud.service"];
        partOf = ["docker-wud-base.target"];
        wantedBy = ["docker-wud-base.target"];
    };

    systemd.services."docker-network-wud" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f wud";
        };

        script = ''
            docker network inspect wud || docker network create wud --ipv6
        '';

        partOf = [ "docker-wud-base.target" ];
        wantedBy = [ "docker-wud-base.target" ];
    };

    systemd.targets."docker-wud-base" = {

        unitConfig = {
            Description = "wud base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."socket-proxy-wud" = {
      
        image = "lscr.io/linuxserver/socket-proxy:3.2.6";
        #autoStart = true;
        networks = ["wud"];
        hostname = "socket-proxy-wud";

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        environment = {
            CONTAINERS = "1";
            IMAGES = "1";
            DISTRIBUTION = "1";
            LOG_LEVEL = "info";
            TZ = "America/Chicago";
        };

        extraOptions = [
            "--tmpfs=/run"
            "--read-only"
            "--memory=64m"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            #"wud.link.template" = "https://github.com/getwud/wud/releases/tag/$${major}.$${minor}.$${patch}";
        };
    };

    virtualisation.oci-containers.containers."wud" = {

        image = "ghcr.io/getwud/wud:8.1.1";
        #autoStart = true;
        ports = ["9999:3000"];
        networks = ["wud"];
        hostname = "wud";

        volumes = [
            "wud_data:/store"
        ];

        environment = {
            TZ = "America/Chicago";
            WUD_WATCHER_LOCAL_HOST = "socket-proxy-wud";
            WUD_WATCHER_LOCAL_WATCHBYDEFAULT = "false";
            WUD_WATCHER_LOCAL_PORT = "2375";
            #WUD_WATCHER_$HOSTNAME_SOCKET = "";
            WUD_WATCHER_LOCAL_CRON = "0 1 * * *";
            WUD_TRIGGER_APPRISE_LOCAL_URL = "https://apprise.azollerstuff.xyz";
        };

        environmentFiles = [
            /home/azoller/containers/wud/env
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/getwud/wud/releases/tag/${major}.${minor}.${patch}";
        };
    };
}
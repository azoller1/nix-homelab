{ config, lib, pkgs, ...}:

{

    systemd.services."docker-diun" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-diun.service"];
        requires = ["docker-network-diun.service"];
        partOf = ["docker-diun-base.target"];
        wantedBy = ["docker-diun-base.target"];
    };

    systemd.services."docker-socket-proxy-diun" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-diun.service"];
        requires = ["docker-network-diun.service"];
        partOf = ["docker-diun-base.target"];
        wantedBy = ["docker-diun-base.target"];
    };

    systemd.services."docker-network-diun" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f diun";
        };

        script = ''
            docker network inspect diun || docker network create diun --ipv6
        '';

        partOf = [ "docker-diun-base.target" ];
        wantedBy = [ "docker-diun-base.target" ];
    };

    systemd.targets."docker-diun-base" = {

        unitConfig = {
            Description = "diun base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."socket-proxy-diun" = {
      
        image = "lscr.io/linuxserver/socket-proxy:3.2.6";
        #autoStart = true;
        networks = ["diun"];
        hostname = "socket-proxy-diun";

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
            "diun.enable" = "true";
            "diun.include_tags" = "^[3-4]\.\d+\..*";
        };
    };

    virtualisation.oci-containers.containers."diun" = {

        image = "ghcr.io/crazy-max/diun:4.30.0";
        #autoStart = true;
        networks = ["diun"];
        hostname = "diun";

        volumes = [
            "diun_data:/data"
        ];

        environment = {
            TZ = "America/Chicago";
            DIUN_WATCH_WORKERS = "10";
            LOG_LEVEL = "info";
            DIUN_WATCH_SCHEDULE = "0 6 * * *";
            DIUN_WATCH_JITTER = "30s";
            DIUN_PROVIDERS_DOCKER = "true";
            DIUN_PROVIDERS_DOCKER_ENDPOINT = "tcp://socket-proxy-diun:2375";
            DIUN_NOTIF_SIGNALREST_ENDPOINT = "https://signal-api.azollerstuff.xyz/v2/send";
            #DIUN_WATCH_FIRSTCHECKNOTIF = "true";
            DIUN_DEFAULTS_WATCHREPO = "true";
            DIUN_DEFAULTS_MAXTAGS = "2";
            #DIUN_DEFAULTS_SORTTAGS = "reverse";
            DIUN_DEFAULTS_EXCLUDETAGS = "latest;main;stable;edge";
            #DIUN_DEFAULTS_INCLUDETAGS = "^([0-9]\d*)\.([0-9]\d*)\.([0-9]\d*)?$";
        };

        environmentFiles = [
            /home/azoller/containers/diun/.env
        ];

        labels = {
            "traefik.enable" = "false";
            "diun.enable" = "true";
            "diun.include_tags" = "^[4-5]\.\d+\..*";
        };
    };
}
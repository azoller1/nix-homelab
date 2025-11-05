{ config, lib, pkgs, ...}:

{
    systemd.services."docker-n8n" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-n8n.service"];
        requires = ["docker-network-n8n.service"];
        partOf = ["docker-n8n-base.target"];
        wantedBy = ["docker-n8n-base.target"];
    };

    systemd.services."docker-n8n-runner" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-n8n.service"];
        requires = ["docker-network-n8n.service"];
        partOf = ["docker-n8n-base.target"];
        wantedBy = ["docker-n8n-base.target"];
    };

    systemd.services."docker-network-n8n" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f n8n";
        };

        script = ''
            docker network inspect n8n || docker network create n8n --ipv6
        '';

        partOf = [ "docker-n8n-base.target" ];
        wantedBy = [ "docker-n8n-base.target" ];
    };

    systemd.targets."docker-n8n-base" = {

        unitConfig = {
            Description = "n8n base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."n8n" = {

        image = "docker.io/n8nio/n8n:1.118.0";
        ports = [ "10015:5678" ];
        networks = ["n8n"];
        hostname = "n8n";

        volumes = [
            "n8n_data:/home/node/.n8n"
        ];

        environment = {
            GENERIC_TIMEZONE = "America/Chicago";
            TZ = "America/Chicago";
            DB_SQLITE_POOL_SIZE = "1";
            N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
            N8N_RUNNERS_ENABLED = "true";
            N8N_RUNNERS_MODE = "external";
            N8N_RUNNERS_BROKER_LISTEN_ADDRESS = "0.0.0.0";
            N8N_NATIVE_PYTHON_RUNNER = "true";
        };

        environmentFiles = [
            /home/azoller/containers/n8n/env
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "traefik.enable" = "true";
            "traefik.http.services.n8n.loadbalancer.server.port" = "10015";
            "traefik.http.routers.n8n.rule" = "Host(`n8n.azollerstuff.xyz`)";
            "traefik.http.routers.n8n.entrypoints" = "https";
            "traefik.http.routers.n8n.tls" = "true";
            "traefik.http.routers.n8n.tls.certresolver" = "le";
            "traefik.http.routers.n8n.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.n8n.middlewares" = "secheader@file";
        };
    };

    virtualisation.oci-containers.containers."n8n-runner" = {

        image = "docker.io/n8nio/runners:1.118.0";
        networks = ["n8n"];
        hostname = "n8n-runner";

        environment = {
            GENERIC_TIMEZONE = "America/Chicago";
            TZ = "America/Chicago";
            N8N_RUNNERS_TASK_BROKER_URI = "http://n8n:5679";
        };

        environmentFiles = [
            /home/azoller/containers/n8n/env
        ];

        dependsOn = [
            "n8n"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "traefik.enable" = "false";
        };
    };
}
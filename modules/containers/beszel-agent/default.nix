{ config, lib, pkgs, ...}:

{
    systemd.services."docker-beszel-agent" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-beszel-agent.service"];
        requires = ["docker-network-beszel-agent.service"];
        partOf = ["docker-beszel-agent-base.target"];
        wantedBy = ["docker-beszel-agent-base.target"];
    };

    systemd.services."docker-socket-proxy-beszel" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-beszel-agent.service"];
        requires = ["docker-network-beszel-agent.service"];
        partOf = ["docker-beszel-agent-base.target"];
        wantedBy = ["docker-beszel-agent-base.target"];
    };

    systemd.services."docker-network-beszel-agent" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = false;
            #ExecStop = "docker network rm -f beszel";
        };

        script = ''
            docker network inspect beszel || docker network create beszel --ipv6
        '';

        partOf = [ "docker-beszel-agent-base.target" ];
        wantedBy = [ "docker-beszel-agent-base.target" ];
    };

    systemd.targets."docker-beszel-agent-base" = {

        unitConfig = {
            Description = "beszel-agent base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."socket-proxy-beszel" = {
      
        image = "lscr.io/linuxserver/socket-proxy:3.2.6";
        #autoStart = true;
        networks = ["beszel"];
        hostname = "socket-proxy-beszel";

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        environment = {
            CONTAINERS = "1";
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
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
        };
    };

    virtualisation.oci-containers.containers."beszel-agent" = {

        image = "ghcr.io/henrygd/beszel/beszel-agent:0.14.0";
        #autoStart = true;
        ports = ["45876:45876"];
        networks = ["beszel"];
        hostname = "beszel-agent";

        environment = {
            LISTEN = "45876";
            HUB_URL = "https://stats.azollerstuff.xyz";
            DOCKER_HOST = "tcp://socket-proxy-beszel:2375";
            KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHjnUWIIjbWBWrZhZUiItXjHh1A5wo+8ABvWunvCfTb";
        };

        volumes = [
            "beszel-agent_data:/var/lib/beszel-agent"
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/henrygd/beszel/releases";
        };
    };
}
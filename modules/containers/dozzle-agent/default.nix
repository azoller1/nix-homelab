{ config, lib, pkgs, ...}:

{
    systemd.services."docker-dozzle-agent" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-dozzle-agent.service"];
        requires = ["docker-network-dozzle-agent.service"];
        partOf = ["docker-dozzle-agent-base.target"];
        wantedBy = ["docker-dozzle-agent-base.target"];
    };

    systemd.services."docker-network-dozzle-agent" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f dozzle-agent";
        };

        script = ''
            docker network inspect dozzle-agent || docker network create dozzle-agent --ipv6
        '';

        partOf = [ "docker-dozzle-agent-base.target" ];
        wantedBy = [ "docker-dozzle-agent-base.target" ];
    };

    systemd.targets."docker-dozzle-agent-base" = {

        unitConfig = {
            Description = "Dozzle Agent Base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."dozzle-agent" = {

        image = "docker.io/amir20/dozzle:v8.14.5";
        #autoStart = true;
        ports = ["7007:7007"];
        networks = ["dozzle-agent"];
        hostname = "dozzle-agent";
        cmd = ["agent"];

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        labels = {
            "traefik.enable" = "false";
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/amir20/dozzle/releases/tag/v${major}.${minor}.${patch}";
        };
    };
}
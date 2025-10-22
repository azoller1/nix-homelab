{ config, lib, pkgs, ...}:

{

    systemd.services."docker-necesse" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-necesse.service"];
        requires = ["docker-network-necesse.service"];
        partOf = ["docker-necesse-base.target"];
        wantedBy = ["docker-necesse-base.target"];
    };

    systemd.services."docker-network-necesse" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f necesse";
        };

        script = ''
            docker network inspect necesse || docker network create necesse --ipv6
        '';

        partOf = [ "docker-necesse-base.target" ];
        wantedBy = [ "docker-necesse-base.target" ];
    };

    systemd.targets."docker-necesse-base" = {

        unitConfig = {
            Description = "necesse base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."necesse" = {

        image = "git.azollerstuff.xyz/azoller/necesse:1.0.1-v2";
        #autoStart = true;
        ports = ["14159:14159/udp"];
        networks = ["necesse"];
        hostname = "necesse";

        volumes = [
            "necesse_data:/home/necesse/.config/Necesse"
        ];

        environment = {
            WORLD_NAME = "warehouse";
        };

        labels = {
            "traefik.enable" = "false";
        };
    };
}
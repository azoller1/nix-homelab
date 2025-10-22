{ config, lib, pkgs, ...}:

{
    systemd.services."docker-baikal-dav" = {

        serviceConfig = {
            Restart = lib.mkOverride 90 "always";
        };
        
        after = ["docker-network-baikal-dav.service"];
        requires = ["docker-network-baikal-dav.service"];
        partOf = ["docker-baikal-dav-base.target"];
        wantedBy = ["docker-baikal-dav-base.target"];
    };

    systemd.services."docker-network-baikal-dav" = {

        path = [ pkgs.docker ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            #ExecStop = "docker network rm -f baikal-dav";
        };

        script = ''
            docker network inspect baikal-dav || docker network create baikal-dav --ipv6
        '';

        partOf = [ "docker-baikal-dav-base.target" ];
        wantedBy = [ "docker-baikal-dav-base.target" ];
    };

    systemd.targets."docker-baikal-dav-base" = {

        unitConfig = {
            Description = "baikal-dav base Service";
        };

        wantedBy = [ "multi-user.target" ];
    };

    virtualisation.oci-containers.containers."baikal-dav" = {

        image = "docker.io/ckulka/baikal:0.10.1-nginx-php8.2";
        #autoStart = true;
        ports = [ "10001:80" ];
        networks = ["baikal-dav"];
        hostname = "baikal-dav";

        volumes = [
            "baikal-dav_config:/var/www/baikal/config"
            "baikal-dav_data:/var/www/baikal/Specific"
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.5";
            "traefik.enable" = "true";
            "traefik.http.services.baikal-dav.loadbalancer.server.port" = "10001";
            "traefik.http.routers.baikal-dav.rule" = "Host(`dav.azollerstuff.xyz`)";
            "traefik.http.routers.baikal-dav.entrypoints" = "https";
            "traefik.http.routers.baikal-dav.tls" = "true";
            "traefik.http.routers.baikal-dav.tls.certresolver" = "le";
            "traefik.http.routers.baikal-dav.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.baikal-dav.middlewares" = "secheader@file";
        };
    };
}
{
    virtualisation.oci-containers.containers."jellyfin" = {

        image = "docker.io/jellyfin/jellyfin:10.11.6";
        ports = ["8096:8096/tcp" "7359:7359/udp"];
        hostname = "jellyfin";
        networks = ["jellyfin"];
        user = "1000:100";


        volumes = [
            "/mnt/hdd/media/data/jelly:/media/jelly"
            "jellyfin_config:/config"
            "jellyfin_cache:/cache"
        ];

        devices = [
            "/dev/dri/card1:/dev/dri/card1"
            "/dev/dri/renderD128:/dev/dri/renderD128"
            "/dev/kfd:/dev/kfd"
        ];

        environment = {
            JELLYFIN_PublishedServerUrl = "https://jelly.zollerlab.com";
        };

        #extraOptions = [
        #    "--network=host"
        #];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
            "traefik.http.routers.jellyfin.rule" = "Host(`jelly.zollerlab.com`)";
            "traefik.http.routers.jellyfin.entrypoints" = "https";
            "traefik.http.routers.jellyfin.tls" = "true";
            "traefik.http.routers.jellyfin.tls.certresolver" = "le";
            "traefik.http.routers.jellyfin.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.jellyfin.middlewares" = "secheader@file";
        };
    };
}
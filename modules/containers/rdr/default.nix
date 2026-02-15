{
    virtualisation.oci-containers.containers."radarr" = {

        image = "ghcr.io/linuxserver/radarr:6.0.4";
        hostname = "radarr";
        networks = ["radarr"];
        #user = "1000:100";


        volumes = [
            "radarr_data:/config"
            "/mnt/hdd/media/data:/media"
            "radarr_empty:/movies"
            "radarr_empty:/downloads"
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
            "traefik.http.routers.radarr.rule" = "Host(`rdr.zollerlab.com`)";
            "traefik.http.routers.radarr.entrypoints" = "https";
            "traefik.http.routers.radarr.tls" = "true";
            "traefik.http.routers.radarr.tls.certresolver" = "le";
            "traefik.http.routers.radarr.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.radarr.middlewares" = "secheader@file";
        };
    };
}
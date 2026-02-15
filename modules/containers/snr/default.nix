{
    virtualisation.oci-containers.containers."sonarr" = {

        image = "ghcr.io/linuxserver/sonarr:4.0.16";
        hostname = "sonarr";
        networks = ["sonarr"];
        #user = "1000:100";


        volumes = [
            "sonarr_data:/config"
            "/mnt/hdd/media/data:/media"
            "sonarr_empty:/tv"
            "sonarr_empty:/downloads"
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";
            "traefik.http.routers.sonarr.rule" = "Host(`snr.zollerlab.com`)";
            "traefik.http.routers.sonarr.entrypoints" = "https";
            "traefik.http.routers.sonarr.tls" = "true";
            "traefik.http.routers.sonarr.tls.certresolver" = "le";
            "traefik.http.routers.sonarr.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.sonarr.middlewares" = "secheader@file";
        };
    };
}
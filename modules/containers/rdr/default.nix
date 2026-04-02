{
    virtualisation.oci-containers.containers."radarr" = {

        image = "ghcr.io/linuxserver/radarr:amd64-latest@sha256:5f5fcfdd7651b71a78394973242efac2cb441193d58bc364b8c4a21620364828";
        hostname = "radarr";
        networks = ["radarr"];
        ports = ["127.0.0.1:20011:7878"];
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

        # labels = {
        #     "traefik.enable" = "true";
        #     "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
        #     "traefik.http.routers.radarr.rule" = "Host(`rdr.zollerlab.com`)";
        #     "traefik.http.routers.radarr.entrypoints" = "https";
        #     "traefik.http.routers.radarr.tls" = "true";
        #     "traefik.http.routers.radarr.tls.certresolver" = "le";
        #     "traefik.http.routers.radarr.tls.domains[0].main" = "*.zollerlab.com";
        #     "traefik.http.routers.radarr.middlewares" = "secheader@file";
        #     "traefik.http.routers.radarr.observability.accesslogs" = "false";
        # };
    };
}

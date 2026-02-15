{
    virtualisation.oci-containers.containers."nzbget" = {

        image = "ghcr.io/nzbgetcom/nzbget:v26.0";
        hostname = "nzbget";
        networks = ["nzbget"];
        #user = "1000:100";


        volumes = [
            "nzbget_data:/config"
            "/mnt/hdd/media/data/usenet:/media/usenet"
            "nzbget_empty:/downloads"
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/Chicago";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.nzbget.loadbalancer.server.port" = "6789";
            "traefik.http.routers.nzbget.rule" = "Host(`nzbg.zollerlab.com`)";
            "traefik.http.routers.nzbget.entrypoints" = "https";
            "traefik.http.routers.nzbget.tls" = "true";
            "traefik.http.routers.nzbget.tls.certresolver" = "le";
            "traefik.http.routers.nzbget.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.nzbget.middlewares" = "secheader@file";
        };
    };
}
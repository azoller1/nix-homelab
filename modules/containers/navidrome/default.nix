{
    virtualisation.oci-containers.containers."navidrome" = {

        image = "ghcr.io/navidrome/navidrome:0.61.2";
        hostname = "navidrome";
        networks = ["navidrome"];
        ports = ["127.0.0.1:20005:4533"];
        user = "1000:100";


        volumes = [
            "navidrome_data:/data"
            "/mnt/hdd/media/music:/music:ro"
            "/mnt/hdd/media/music-soulsync:/music-flac:ro"
        ];

        environment = {
            ND_LOGLEVEL = "info";
            ND_BASEURL = "https://music.zollerlab.com";
            ND_LISTENBRAINZ_BASEURL = "https://scrobbler.zollerlab.com/1/";
        };

        extraOptions = [
            "--security-opt=no-new-privileges"
        ];

        # labels = {
        #     "traefik.enable" = "true";
        #     "traefik.http.services.navidrome.loadbalancer.server.port" = "4533";
        #     "traefik.http.routers.navidrome.rule" = "Host(`music.zollerlab.com`)";
        #     "traefik.http.routers.navidrome.entrypoints" = "https";
        #     "traefik.http.routers.navidrome.tls" = "true";
        #     "traefik.http.routers.navidrome.tls.certresolver" = "le";
        #     "traefik.http.routers.navidrome.tls.domains[0].main" = "*.zollerlab.com";
        #     "traefik.http.routers.navidrome.middlewares" = "secheader@file";
        #     "traefik.http.routers.navidrome.observability.accesslogs" = "false";
        # };
    };
}

{
    virtualisation.oci-containers.containers."jellyfin" = {

        image = "docker.io/jellyfin/jellyfin:10.11.0";
        autoStart = true;
        hostname = "jellyfin";

        volumes = [
            "/mnt/hdd/media/jelly:/media"
            "jellyfin_config:/config"
            "jellyfin_cache:/cache"
        ];

        devices = [
            "/dev/dri/card1:/dev/dri/card1"
            "/dev/dri/renderD128:/dev/dri/renderD128"
            "/dev/kfd:/dev/kfd"
        ];

        environment = {
            JELLYFIN_PublishedServerUrl = "https://jelly.azollerstuff.xyz";
        };

        extraOptions = [
            "--network=host"
        ];

        labels = {
            "wud.watch" = "true";
            "wud.tag.include" = "^[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/jellyfin/jellyfin/releases";
            "traefik.enable" = "true";
            "traefik.http.services.jellyfin.loadbalancer.server.url" = "http://192.168.2.2:8096";
            "traefik.http.routers.jellyfin.rule" = "Host(`jelly.azollerstuff.xyz`)";
            "traefik.http.routers.jellyfin.entrypoints" = "https";
            "traefik.http.routers.jellyfin.tls" = "true";
            "traefik.http.routers.jellyfin.tls.certresolver" = "le";
            "traefik.http.routers.jellyfin.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.jellyfin.middlewares" = "secheader@file";
        };
    };
}
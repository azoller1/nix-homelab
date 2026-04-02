{
    virtualisation.oci-containers.containers."openweb" = {

        image = "ghcr.io/open-webui/open-webui:main";
        hostname = "openweb";
        ports = ["127.0.0.1:20008:8080"];
        networks = ["openweb"];

        volumes = [
            "openweb_data:/app/backend/data"
        ];

        environment = {
            TZ = "America/Chicago";
        };

        extraOptions = [
            "--add-host=host.docker.internal:host-gateway"
        ];

        # labels = {
        #     "traefik.enable" = "true";
        #     "traefik.http.services.openweb.loadbalancer.server.port" = "8080";
        #     "traefik.http.routers.openweb.rule" = "Host(`openweb.zollerlab.com`)";
        #     "traefik.http.routers.openweb.entrypoints" = "https";
        #     "traefik.http.routers.openweb.tls" = "true";
        #     "traefik.http.routers.openweb.tls.certresolver" = "le";
        #     "traefik.http.routers.openweb.tls.domains[0].main" = "*.zollerlab.com";
        #     "traefik.http.routers.openweb.middlewares" = "secheader@file";
        #     "traefik.http.routers.openweb.observability.accesslogs" = "false";
        # };
    };
}

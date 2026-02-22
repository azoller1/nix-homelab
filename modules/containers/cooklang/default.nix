{
    virtualisation.oci-containers.containers."cooklang" = {

        image = "git.zollerlab.com/azoller/cooklang-chef:latest";
        hostname = "cooklang";
        networks = ["cooklang"];
        #user = "1000:100";


        volumes = [
            "/home/azoller/containers/cooklang:/recipes"
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.cooklang.loadbalancer.server.port" = "9080";
            "traefik.http.routers.cooklang.rule" = "Host(`cooking.zollerlab.com`)";
            "traefik.http.routers.cooklang.entrypoints" = "https";
            "traefik.http.routers.cooklang.tls" = "true";
            "traefik.http.routers.cooklang.tls.certresolver" = "le";
            "traefik.http.routers.cooklang.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.cooklang.middlewares" = "secheader@file";
        };
    };
}
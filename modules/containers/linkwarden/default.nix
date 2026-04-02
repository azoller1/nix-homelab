{
    virtualisation.oci-containers.containers."linkwarden" = {

        image = "ghcr.io/linkwarden/linkwarden:v2.14.0";
        ports = [ "20006:3000" ];
        networks = ["linkwarden"];
        hostname = "linkwarden";

        volumes = [
            "linkwarden_data:/data/data"
        ];

        environmentFiles = [
            /home/azoller/containers/linkwarden/env
        ];

        dependsOn = [
            "meili-linkwarden"
        ];

        # labels = {
        #     "kop.bind.ip" = "192.168.2.5";
        #     "traefik.enable" = "true";
        #     "traefik.http.services.linkwarden.loadbalancer.server.port" = "10023";
        #     "traefik.http.routers.linkwarden.rule" = "Host(`links.zollerlab.com`)";
        #     "traefik.http.routers.linkwarden.entrypoints" = "https";
        #     "traefik.http.routers.linkwarden.tls" = "true";
        #     "traefik.http.routers.linkwarden.tls.certresolver" = "le";
        #     "traefik.http.routers.linkwarden.tls.domains[0].main" = "*.zollerlab.com";
        #     "traefik.http.routers.linkwarden.middlewares" = "secheader@file";
        # };
    };

    virtualisation.oci-containers.containers."meili-linkwarden" = {

        image = "docker.io/getmeili/meilisearch:v1.36.0";
        networks = ["linkwarden"];
        hostname = "meili-linkwarden";

        volumes = [
            "meili_linkwarden_data:/meili_data"
        ];

        # labels = {
        #     "traefik.enable" = "false";
        # };
    };
}

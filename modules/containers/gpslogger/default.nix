{
    virtualisation.oci-containers.containers."geopulse-ui" = {

        image = "ghcr.io/tess1o/geopulse-ui:1.19.0";
        ports = [ "10005:80" ];
        networks = ["geopulse"];
        hostname = "geopulse-ui";

        dependsOn = [
            "geopulse"
        ];

        environmentFiles = [
            /home/azoller/containers/geopulse/.env
        ];

        labels = {
            "kop.bind.ip" = "192.168.2.6";
            "traefik.enable" = "true";
            "traefik.http.services.geopulse.loadbalancer.server.port" = "10005";
            "traefik.http.routers.geopulse.rule" = "Host(`geopulse.zollerlab.com`)";
            "traefik.http.routers.geopulse.entrypoints" = "https";
            "traefik.http.routers.geopulse.tls" = "true";
            "traefik.http.routers.geopulse.tls.certresolver" = "le";
            "traefik.http.routers.geopulse.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.geopulse.middlewares" = "secheader@file,default-geoblock@file,my-robots-txt@file";
            #"traefik.http.middlewares.secured.chain.middlewares" = "secheader@file,default-geoblock@file";
        };
    };

    virtualisation.oci-containers.containers."geopulse" = {

        image = "ghcr.io/tess1o/geopulse-backend:1.19.0-native";
        networks = ["geopulse"];
        hostname = "geopulse";

        volumes = [
            "geopulse_keys:/app/keys"
        ];

        environmentFiles = [
            /home/azoller/containers/geopulse/.env
        ];

        extraOptions = [
            "--memory=512m"
        ];
    };
}

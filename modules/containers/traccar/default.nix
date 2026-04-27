{
    virtualisation.oci-containers.containers."traccar" = {

        image = "docker.io/traccar/traccar:6.12.2-alpine";
        networks = ["traccar"];
        ports = ["127.0.0.1:20016:8082"];
        hostname = "traccar";

        volumes = [
            #"traccar_data:/opt/traccar/data:rw"
            "traccar_logs:/opt/traccar/logs:rw"
            #"/home/azoller/containers/traccar/config.xml:/opt/traccar/conf/traccar.xml:ro"
        ];

        environmentFiles = [
            /home/azoller/containers/traccar/env
        ];

        # labels = {
        #     "traefik.enable" = "true";
        #     "traefik.http.services.traccar.loadbalancer.server.port" = "1411";
        #     "traefik.http.routers.traccar.rule" = "Host(`auth.zollerlab.com`)";
        #     "traefik.http.routers.traccar.entrypoints" = "https";
        #     "traefik.http.routers.traccar.tls" = "true";
        #     "traefik.http.routers.traccar.tls.certresolver" = "le";
        #     "traefik.http.routers.traccar.tls.domains[0].main" = "*.zollerlab.com";
        #     "traefik.http.routers.traccar.middlewares" = "secheader@file";
        # };
    };
}

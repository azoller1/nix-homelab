{
    virtualisation.oci-containers.containers."dozzle" = {

        image = "docker.io/amir20/dozzle:v8.14.5";
        autoStart = true;
        networks = ["dozzle"];
        hostname = "dozzle";

        environment = {
            DOZZLE_REMOTE_AGENT = "192.168.2.2:7007,192.168.2.5:7007,192.168.2.6:7007,192.168.2.7:7007,192.168.2.8:7007,192.168.2.9:7007";
        };

        labels = {
            "traefik.enable" = "true";
            "diun.enable" = "true";
            "traefik.http.services.dozzle.loadbalancer.server.port" = "8080";
            "traefik.http.routers.dozzle.rule" = "Host(`dozzle.azollerstuff.xyz`)";
            "traefik.http.routers.dozzle.entrypoints" = "https";
            "traefik.http.routers.dozzle.tls" = "true";
            "traefik.http.routers.dozzle.tls.certresolver" = "le";
            "traefik.http.routers.dozzle.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.dozzle.middlewares" = "secheader@file";
        };
    };
}
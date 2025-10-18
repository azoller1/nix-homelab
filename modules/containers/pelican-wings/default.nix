{
    virtualisation.oci-containers.containers."pelican-wings" = {

        image = "ghcr.io/pelican-dev/wings:v1.0.0-beta18";
        autoStart = true;
        ports = ["2022:2022" "8080:8080"];
        networks = ["pelican-wings"];
        hostname = "pelican-wings";

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/var/lib/docker/containers/:/var/lib/docker/containers/"
            "/etc/pelican/:/etc/pelican/"
            "/var/lib/pelican/:/var/lib/pelican/"
            "/var/log/pelican/:/var/log/pelican/"
            "/tmp/pelican/:/tmp/pelican/"
            "/etc/ssl/certs:/etc/ssl/certs:ro"
        ];

        environment = {
            TZ = "America/Chicago";
            WINGS_UID = "988";
            WINGS_GID = "988";
            WINGS_USERNAME = "azoller";
        };

        extraOptions = [
        "--tty"
      ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.pelican-wings.loadbalancer.server.port" = "8080";
            "traefik.http.routers.pelican-wings.rule" = "Host(`pelican-wings-main.azollerstuff.xyz`)";
            "traefik.http.routers.pelican-wings.entrypoints" = "https";
            "traefik.http.routers.pelican-wings.tls" = "true";
            "traefik.http.routers.pelican-wings.tls.certresolver" = "le";
            "traefik.http.routers.pelican-wings.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.pelican-wings.middlewares" = "secheader@file";
        };
    };
}
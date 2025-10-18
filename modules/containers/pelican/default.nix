{
    virtualisation.oci-containers.containers."pelican" = {

        image = "ghcr.io/pelican-dev/panel:v1.0.0-beta26";
        autoStart = true;
        networks = ["pelican"];
        hostname = "pelican";

        volumes = [
            "pelican_data:/pelican_data"
            "pelican_logs:/var/www/html/storage/logs"
            "/home/azoller/containers/pelican/Caddyfile:/etc/caddy/Caddyfile"
        ];

        environment = {
            XDG_DATA_HOME = "/pelican-data";
            APP_URL = "https://pelican.azollerstuff.xyz";
            ADMIN_EMAIL = "homelab+pelican@alexanderzoller.com";
        };

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.pelican.loadbalancer.server.port" = "80";
            "traefik.http.routers.pelican.rule" = "Host(`pelican.azollerstuff.xyz`)";
            "traefik.http.routers.pelican.entrypoints" = "https";
            "traefik.http.routers.pelican.tls" = "true";
            "traefik.http.routers.pelican.tls.certresolver" = "le";
            "traefik.http.routers.pelican.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.pelican.middlewares" = "secheader@file";
        };
    };
}
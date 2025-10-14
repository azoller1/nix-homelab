{
    virtualisation.oci-containers.containers."romm" = {

        image = "ghcr.io/rommapp/romm:4.3.0";
        autoStart = true;
        networks = ["romm"];
        hostname = "romm";

        volumes = [
            "romm_data:/romm/resources"
            "romm_redis_data:/redis-data"
            "/mnt/data/romm/library:/romm/library"
            "/mnt/data/romm/assets:/romm/assets"
        ];

        environmentFiles = [
            /home/azoller/nix-homelab/hosts/main-server/.env.secret.romm
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.romm.loadbalancer.server.port" = "8080";
            "traefik.http.routers.romm.rule" = "Host(`romm.azollerstuff.xyz`)";
            "traefik.http.routers.romm.entrypoints" = "https";
            "traefik.http.routers.romm.tls" = "true";
            "traefik.http.routers.romm.tls.certresolver" = "le";
            "traefik.http.routers.romm.tls.domains[0].main" = "*.azollerstuff.xyz";
            "traefik.http.routers.romm.middlewares" = "secheader@file";
        };
    };
}

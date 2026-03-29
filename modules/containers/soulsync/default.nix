{
    virtualisation.oci-containers.containers."soulsync" = {

        image = "docker.io/boulderbadgedad/soulsync:2.1@sha256:c1cb8a59210b371cb5d6bde1570342bfdded7c443212f95ad712f4d885870ec9";
        hostname = "soulsync";
        networks = ["soulsync"];
        #ports = ["8882:8008"];
        #user = "1000:100";


        volumes = [
            "ss_db:/app/data"
            "/mnt/hdd/media/music-soulsync:/app/Transfer"
            "/mnt/hdd/media/music-downloads:/app/downloads"
            "ss_config:/app/config"
            "ss_logs:/app/logs"
            #"ss_downloads:/app/downloads"
            #"ss_staging:/app/Staging"
        ];

        #environmentFiles = [
        #    /home/azoller/containers/ssync/env
        #];

        environment = {
          PUID = "1000";
          PGID = "100";
          UMASK = "022";
          FLASK_ENV = "production";
          PYTHONPATH = "/app";
          SOULSYNC_CONFIG_PATH = "/app/config/config.json";
          TZ = "America/Chicago";
        };

        #extraOptions = [
        #    "--security-opt=no-new-privileges"
        #];

        extraOptions = [
            "--memory=2056m"
        ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.soulsync.loadbalancer.server.port" = "8008";
            "traefik.http.routers.soulsync.rule" = "Host(`ssync.zollerlab.com`)";
            "traefik.http.routers.soulsync.entrypoints" = "https";
            "traefik.http.routers.soulsync.tls" = "true";
            "traefik.http.routers.soulsync.tls.certresolver" = "le";
            "traefik.http.routers.soulsync.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.soulsync.middlewares" = "secheader@file";
            "traefik.http.routers.soulsync.observability.accesslogs" = "false";
        };
    };
}

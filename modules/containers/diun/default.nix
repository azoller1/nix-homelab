{

    virtualisation.oci-containers.containers."socket-proxy-diun" = {
      
        image = "lscr.io/linuxserver/socket-proxy:3.2.4";
        autoStart = true;
        networks = ["diun"];
        hostname = "socket-proxy-diun";

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        environment = {
            CONTAINERS = "1";
            IMAGES = "1";
            DISTRIBUTION = "1";
            LOG_LEVEL = "info";
            TZ = "America/Chicago";
        };

        extraOptions = [
            "--tmpfs=/run"
            "--read-only"
            "--memory=64m"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
        ];

        labels = {
            "diun.enable" = "true";
        };
    };

    virtualisation.oci-containers.containers."diun" = {

        image = "ghcr.io/crazy-max/diun:4.30.0";
        autoStart = true;
        networks = ["diun"];
        hostname = "diun";

        volumes = [
            "diun_data:/data"
        ];

        environment = {
            TZ = "America/Chicago";
            DIUN_WATCH_WORKERS = "10";
            LOG_LEVEL = "info";
            DIUN_WATCH_SCHEDULE = "0 6 * * *";
            DIUN_WATCH_JITTER = "30s";
            DIUN_PROVIDERS_DOCKER = "true";
            DIUN_NOTIF_SIGNALREST_ENDPOINT = "https://signal-api.azollerstuff.xyz/v2/send";
            DIUN_PROVIDERS_DOCKER_ENDPOINT = "tcp://socket-proxy-diun:2375";
        };

        environmentFiles = [
            /home/azoller/containers/diun/.env
        ];

        labels = {
            "traefik.enable" = "false";
            "diun.enable" = "true";
        };
    };
}
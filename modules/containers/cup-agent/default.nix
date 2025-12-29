{ config, lib, pkgs, ...}:

{

    virtualisation.oci-containers.containers."socket-proxy-cup" = {

        image = "lscr.io/linuxserver/socket-proxy:3.2.6";
        networks = ["cup"];
        hostname = "socket-proxy-cup";

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
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."cup" = {

        image = "ghcr.io/sergi0g/cup:v3.5.1";
        ports = ["9005:8000"];
        networks = ["cup"];
        hostname = "cup";
        cmd = ["serve"];

        environment = {
            CUP_AGENT = "true";
            #CUP_IGNORE_UPDATE_TYPE = "major";
            CUP_REFRESH_INTERVAL = "0 */30 * * * *";
            CUP_SOCKET = "tcp://socket-proxy-cup:2375";
            CUP_THEME = "blue";
        };

        labels = {
            #"kop.bind.ip" = "192.168.2.5";
            #"cup.watch" = "true";
            #"cup.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            #"cup.link.template" = "https://github.com/hargata/lubelog/releases";
            "traefik.enable" = "false";
        };
    };
}
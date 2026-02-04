{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."dozzle-agent" = {

        image = "docker.io/amir20/dozzle:v9.0.3";
        autoStart = true;
        ports = ["7007:7007"];
        networks = ["dozzle-agent"];
        hostname = "dozzle-agent";
        cmd = ["agent"];

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };
}

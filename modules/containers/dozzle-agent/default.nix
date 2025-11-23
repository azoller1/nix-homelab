{ config, lib, pkgs, ...}:

{
    virtualisation.oci-containers.containers."dozzle-agent" = {

        image = "docker.io/amir20/dozzle:v8.14.9";
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
            "wud.watch" = "true";
            "wud.tag.include" = "^v[0-9]+.[0-9]+.[0-9]+$";
            "wud.link.template" = "https://github.com/amir20/dozzle/releases";
        };
    };
}

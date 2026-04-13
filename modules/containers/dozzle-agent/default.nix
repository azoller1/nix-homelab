{
    virtualisation.oci-containers.containers."dozzle-agent" = {

        image = "docker.io/amir20/dozzle:v10.3.1";
        ports = ["7007:7007"];
        networks = ["dozzle-agent"];
        hostname = "dozzle-agent";
        cmd = ["agent"];

        volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];

        # labels = {
        #     "traefik.enable" = "false";
        # };
    };
}

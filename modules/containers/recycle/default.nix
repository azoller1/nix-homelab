{
    virtualisation.oci-containers.containers."recyclarr" = {

        image = "ghcr.io/recyclarr/recyclarr:7.5.2";
        hostname = "recyclarr";
        networks = ["recyclarr"];
        user = "1000:100";


        volumes = [
            "recyclarr_data:/config"
        ];

        environment = {
            TZ = "America/Chicago";
        };

        labels = {
            "traefik.enable" = "false";
        };
    };
}
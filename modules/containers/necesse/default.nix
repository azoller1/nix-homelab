{
    virtualisation.oci-containers.containers."necesse" = {

        image = "git.azollerstuff.xyz/azoller/necesse:1.0.1";
        autoStart = true;
        ports = ["14159:14159"];
        networks = ["necesse"];
        hostname = "necesse";

        volumes = [
            "necesse_data:/home/necesse/.config/Necesse"
        ];

        environment = {
            WORLD_NAME = "warehouse";
        };

        labels = {
            "traefik.enable" = "false";
        };
    };
}
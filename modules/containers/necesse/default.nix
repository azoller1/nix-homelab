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
            PORT = "14159";
            #PASSWORD = "";
            BIND_IP = "192.168.2.2";
            MOTD = "Hi";
            WORLD_NAME = "warehouse";
            ANTI_CHEAT = "0";
            PLAYER_SLOTS = "2";
            PAUSE = "1";
        };

        labels = {
            "traefik.enable" = "false";
        };
    };
}
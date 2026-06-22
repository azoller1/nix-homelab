{

    virtualisation.oci-containers.containers."ignis" = {

        image = "git.zollerlab.com/azoller/ignis-obsidian:0.8.5";
        ports = [ "20009:8080" ];
        networks = ["ignis"];
        hostname = "ignis";

        environment = {
            PGID = "100";
            AUTO_CREATE_DEFAULT = "true";
        };

        volumes = [
            "ignis_data:/app/obsidian-app"
            "ignis_vault_data:/vaults"
            "ignis_app_data:/app/data"
        ];

    };
}

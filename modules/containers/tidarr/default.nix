{
    virtualisation.oci-containers.containers."tidarr" = {

        image = "git.zollerlab.com/azoller/tidarr:latest@sha256:b824ce88fd5e2d20fda147feb3b8004451c1aff72256cd1aebb961fdca68f454";
        networks = ["tidarr"];
        ports = ["20017:8484"];
        hostname = "tidarr";

        volumes = [
            "tidarr_config:/shared"
            "/mnt/hdd/media/music-downloads:/music"
        ];

        environment = {
            PUID = "1000";
            PGID = "100";
            LOCK_QUALITY = "true";
            ENABLE_HISTORY = "true";
            ENABLE_BEETS = "true";
        };

        environmentFiles = [
            /home/azoller/containers/tidarr/env
        ];
    };
}

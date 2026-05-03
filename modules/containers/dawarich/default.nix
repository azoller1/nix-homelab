{
    virtualisation.oci-containers.containers."dawarich-valkey" = {

        image = "docker.io/valkey/valkey:9-trixie";
        networks = ["dawarich"];
        hostname = "dawarich-valkey";

        volumes = [
            "dawarich_valkey_data:/data"
        ];

        cmd = [
            "valkey-server"
            "--save 30 1"
            "--loglevel warning"
        ];
    };

    virtualisation.oci-containers.containers."dawarich" = {

        image = "docker.io/freikin/dawarich:1.7.4";
        ports = [ "20008:3000" ];
        networks = ["dawarich"];
        hostname = "dawarich_app";

        volumes = [
            "dawarich_public:/var/app/public"
            "dawarich_watched:/var/app/tmp/imports/watched"
            "dawarich_data:/var/app/storage"
        ];

        #extraOptions = [
        #    "--tty"
        #    "--interactive"
        #];

        cmd = ["bin/rails" "server" "-p" "3000" "-b" "::"];

        dependsOn = [
            "dawarich-valkey"
        ];

        entrypoint = "web-entrypoint.sh";

        environmentFiles = [
            "/home/azoller/containers/dawarich/env"
        ];
    };

    virtualisation.oci-containers.containers."dawarich-side" = {

        image = "docker.io/freikin/dawarich:1.7.4";
        networks = ["dawarich"];
        hostname = "dawarich_sidekiq";

        volumes = [
            "dawarich_public:/var/app/public"
            "dawarich_watched:/var/app/tmp/imports/watched"
            "dawarich_data:/var/app/storage"
        ];

        #extraOptions = [
        #    "--tty"
        #    "--interactive"
        #];

        cmd = ["sidekiq"];

        dependsOn = [
            "dawarich-valkey"
            "dawarich"
        ];

        entrypoint = "sidekiq-entrypoint.sh";

        environmentFiles = [
            "/home/azoller/containers/dawarich/side-env"
        ];

    };
}

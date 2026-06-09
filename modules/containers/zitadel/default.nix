{
    virtualisation.oci-containers.containers."zitadel-api" = {

        image = "ghcr.io/zitadel/zitadel:v4.15.0@sha256:cc9fb3b2788dcbd0dff93781a0323bbe491a4cec11e1caefd9a1ed31f7fdc145";
        networks = ["zitadel"];
        ports = ["127.0.0.1:20017:8080"];
        hostname = "zitadel-api";

        volumes = [
            "zitadel-bootstrap:/zitadel/bootstrap"
        ];

        environmentFiles = [
            /home/azoller/containers/zitadel/env
        ];

        cmd = [
            "start-from-init"
            "--masterkey"
        ];
    };

    virtualisation.oci-containers.containers."zitadel-web" = {

        image = "ghcr.io/zitadel/zitadel-login:v4.15.0@sha256:e747907836df115d65a58ab0cab7bb2626764ec679e5585dd199797c090124bd";
        networks = ["zitadel"];
        ports = ["127.0.0.1:20018:3000"];
        hostname = "zitadel-web";

        volumes = [
            "zitadel-bootstrap:/zitadel/bootstrap:ro"
        ];

        environmentFiles = [
            /home/azoller/containers/zitadel/env
        ];

    };
}

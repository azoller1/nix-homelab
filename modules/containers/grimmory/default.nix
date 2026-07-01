{
    virtualisation.oci-containers.containers."grimmory" = {

        image = "git.zollerlab.com/azoller/grimmory:3.2.2";
        networks = ["grimmory"];
        ports = ["20010:6060"];
        hostname = "grimmory";

        volumes = [
            "grimmory_data:/app/data"
            "grimmory_books:/books"
            "grimmory_bookdrop:/bookdrop"
        ];

        environmentFiles = [
            /home/azoller/containers/grimmory/env
        ];
    };
}

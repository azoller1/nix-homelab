{
    virtualisation.oci-containers.containers."filebrowser" = {

        image = "ghcr.io/gtsteffaniak/filebrowser:1.4.0-stable";
        ports = [ "127.0.0.1:20015:80" ];
        networks = ["office-files"];
        hostname = "filebrowser";

        volumes = [
            "/home/azoller/containers/filebrowser/data:/home/filebrowser/data"
            "/mnt/data/cloud-files:/files"
        ];

        environmentFiles = [
            /home/azoller/containers/filebrowser/env
        ];

    };
}

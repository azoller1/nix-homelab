{
    virtualisation.oci-containers.containers."trilium" = {

        image = "ghcr.io/triliumnext/trilium:v0.103.0@sha256:8e6bc939a6d5dbeed42d1b5b155bc790b1c28ca3ac414382d04d626903c62081";
        networks = ["trillium"];
        ports = ["20011:8080"];
        hostname = "trilium";

        volumes = [
            "trilium_data:/home/node/trilium-data"
            "/etc/localtime:/etc/localtime:ro"
        ];

        environmentFiles = [
            /home/azoller/containers/trilium/env
        ];
    };
}

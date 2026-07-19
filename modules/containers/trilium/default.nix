{
    virtualisation.oci-containers.containers."trilium" = {

        image = "ghcr.io/triliumnext/trilium:v0.104.0@sha256:8e053aa58a90c1690106a324a4692690ba0491c21ae40485b4051e2911df9489";
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

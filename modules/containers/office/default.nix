{
    virtualisation.oci-containers.containers."onlyoffice" = {

        image = "docker.io/onlyoffice/documentserver:9.4.0.1";
        ports = [ "127.0.0.1:20014:80" ];
        networks = ["office-files"];
        hostname = "onlyoffice";

        # volumes = [
        #     "onlyoffice_data:/etc/onlyoffice"
        # ];

        environmentFiles = [
            /home/azoller/containers/onlyoffice/env
        ];

    };
}

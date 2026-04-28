{
    virtualisation.oci-containers.containers."crowdsec-webui" = {

        image = "git.zollerlab.com/azoller/crowdsec-webui:latest@sha256:a07ddc2cece343e639cf34543df9ffdc13def135ced7e86a81351302624d0e49";
        ports = [ "20007:3000" ];
        networks = ["crowdsec-webui"];
        hostname = "crowdsec-webui";

        volumes = [
            "crowdsec-webui_data:/app/data"
        ];

        environmentFiles = [
            /home/azoller/containers/crowdsec/env
        ];

        extraOptions = [
            "--security-opt=no-new-privileges"
        ];
    };
}

{

  virtualisation.oci-containers.containers."socket-proxy-scanopy" = {

      image = "lscr.io/linuxserver/socket-proxy:3.2.14";
      networks = ["scanopy"];
      #ports = ["127.0.0.1:2375:2375"];
      hostname = "socket-proxy-scanopy";

      volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
          CONTAINERS = "1";
          NETWORKS = "1";
          EXEC = "1";
          POST = "1";
          INFO = "1";
          LOG_LEVEL = "info";
          TZ = "America/Chicago";
      };

      extraOptions = [
          "--tmpfs=/run"
          "--read-only"
          "--memory=64m"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
      ];
  };

    virtualisation.oci-containers.containers."scanopy-daemon" = {

        image = "ghcr.io/scanopy/scanopy/daemon:v0.15.4@sha256:ce8af2edc17cac9e299df62a0e796b47e71ef415d23a662193a3d20dbcbe703f";
        ports = [ "60073:60073" ];
        #networks = ["scanopy"];
        hostname = "scanopy-daemon";

        environmentFiles = [
            /home/azoller/containers/scanopy/env
        ];

        volumes = [
            "scanopy_config:/root/.config/daemon"
        ];

        extraOptions = [
            "--network=host"
        ];

        labels = {
            "traefik.enable" = "false";
        };
    };

    virtualisation.oci-containers.containers."scanopy-server" = {

        image = "ghcr.io/scanopy/scanopy/server:v0.15.4@sha256:4efe8ea9b1c0bbcaac7547077d6fc703f5019271bafc974cc4e4bb580e0e291b";
        networks = ["scanopy"];
        # ports = ["60072:60072"];
        hostname = "scanopy-server";

        volumes = [
            "scanopy_data:/data"
        ];

        dependsOn = [
            "scanopy-daemon"
        ];

        environmentFiles = [
            /home/azoller/containers/scanopy/env
        ];

        # extraOptions = [
        #     "--memory=512m"
        #     "--security-opt=no-new-privileges"
        # ];

        labels = {
            "traefik.enable" = "true";
            "traefik.http.services.scanopy.loadbalancer.server.port" = "60072";
            "traefik.http.routers.scanopy.rule" = "Host(`scanopy.zollerlab.com`)";
            "traefik.http.routers.scanopy.entrypoints" = "https";
            "traefik.http.routers.scanopy.tls" = "true";
            "traefik.http.routers.scanopy.tls.certresolver" = "le";
            "traefik.http.routers.scanopy.tls.domains[0].main" = "*.zollerlab.com";
            "traefik.http.routers.scanopy.middlewares" = "secheader@file";
            #"traefik.http.middlewares.secured.chain.middlewares" = "secheader@file,default-geoblock@file";
        };
    };
}

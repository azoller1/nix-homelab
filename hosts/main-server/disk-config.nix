{
  disko.devices = {
    disk = {

      ssd1 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x53a5a276780047a0";
        content = {
          type = "gpt";
          partitions = {
            part1 = {
              label = "app-data";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/data";
              };
            };
          };
        };
      };

      ssd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA230315S3051209064";
        content = {
          type = "gpt";
          partitions = {
            part1 = {
              label = "extra-data";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/extra-data";
              };
            };
          };
        };
      };

      hdd = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000c500e49c63dd";
        content = {
          type = "gpt";
          partitions = {
            part1 = {
              label = "hdd-data";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/hdd";
              };
            };
          };
        };
      };

      nvme1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {

            ESP = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };

            };
          };
        };
      };
    };
  };
}
{config, ...}:
{
  networking.firewall.allowedUDPPorts = [ 9001 ];

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "status.home.lan";
        enforce_domain = true;
        http_addr = "127.0.0.1";
        http_port = 2342; 
      };
    };
    provision = {
      enable = true;
      datasources = {
        settings = {
          datasources = [
            {
              name = "prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            }
          ];
        };
      };
    };
  };

  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "lab";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "coredns";
        static_configs = [
          {
            targets = [ "127.0.0.1:9005" ];
          }
        ];
      }
    ];
  };
}

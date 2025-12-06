{config, ...}:
let
  immichSettings = builtins.fromJSON(builtins.readFile ./immich-config.json);
in
{
  services.immich = {
    enable = true;
    settings = immichSettings;
    redis = {
      enable = false; # We need to supply our own redis package
      host = "${config.services.redis.servers.immich.unixSocket}";
    };
    accelerationDevices = null; # Change after verifying that accel works
    host = "127.0.0.1";
    database = {
      enableVectors = false;
    };
    machine-learning.environment = {
      MPLCONFIGDIR = "/var/cache/immich/matplotlib"; # fixes error in dir creation for matplotlib
    };
  };

  services.nginx = {
    virtualHosts = {
      "photos.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        extraConfig = ''
          #ssl_certificate /etc/ssl/certs/home.lan.cert.pem;
          #ssl_certificate_key ${config.sops.secrets."nginx/private_key".path};
          client_max_body_size 1000M;
        '';
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:2283";
            recommendedProxySettings = false;
            extraConfig = ''
              proxy_redirect off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              # WS
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              # timeouts
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
              send_timeout 600s;
            '';
          };
        };
      };
    };
  };

  services.redis = {
    servers.immich = {
      enable = true;
      user = "immich";
      port = 0;
    };
  };
}

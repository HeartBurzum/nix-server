{config, lib, pkgs, ...}:
let
environment = {
      INSECURE = "true";
      PROXY_TLS = "false";
      OC_DOMAIN = "cloud.home.lan";
      OC_INSECURE = "false";
      # TODO: Sops
      OC_JWT_SECRET = "testvalue";
      PROXY_LOG_LEVEL = "warn";
      PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";
      COLLABORA_DOMAIN = "collabora.home.lan";
      COLLABORATION_APP_PRODUCT = "Collabora";
      COLLABORATION_APP_NAME = "CollaboraOnline";
      # TODO: Sops
      COLLABORATION_WOPI_SECRET = "testvalue";
      COLLABORATION_WOPI_SRC = "https://wopiserver.home.lan";
      COLLABORATION_APP_INSECURE = "true";
      COLLABORATION_APP_ADDR = "https://collabora.home.lan";
      COLLABORATION_LOG_LEVEL = "trace";
};

collabora2504 = pkgs.callPackage ./collabora-online-package.nix { };
oc4 = pkgs.callPackage ./opencloud-package.nix { };
in
{
  services.opencloud = {
    enable = true;
    package = oc4;
    address = "127.0.0.1";
    url = "https://cloud.home.lan";
    inherit environment;
    settings.csp.directives = {
      child-src = [ "'self'" ];
      connect-src = [
        "'self'"
        "blob:"
        "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
      ];
      default-src = [ "'none'" ];
      font-src = [ "'self'" ];
      frame-ancestors = [ "'self'" ];
      frame-src = [
        "'self'"
        "blob:"
        "https://embed.diagrams.net"
        "https://collabora.home.lan/"
        "https://docs.opencloud.eu"
      ];
      img-src = [
        "'self'"
        "data:"
        "blob:"
        "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        "https://collabora.home.lan/"
      ];
      manifest-src = [ "'self'" ];
      media-src = [ "'self'" ];
      object-src = [
        "'self'"
        "blob:"
      ];
      script-src = [
        "'self'"
        "'unsafe-inline'"
      ];
      style-src = [
        "'self'"
        "'unsafe-inline'"
      ];
    };
    settings.proxy = builtins.fromJSON(builtins.readFile ./proxy_settings.json);
  };

  systemd.services.opencloud-collaboration = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    inherit environment;
    serviceConfig = config.systemd.services.opencloud.serviceConfig // {
      Type = "simple";
      ExecStartPre = "${lib.getExe' pkgs.coreutils-full "sleep"} 3";
      ExecStart = "${oc4}/bin/opencloud collaboration server";
      WorkingDirectory = "${config.services.opencloud.stateDir}";
      User = "${config.services.opencloud.user}";
      Group = "${config.services.opencloud.group}";
      Restart = "always";
      ReadWritePaths = [ config.services.opencloud.stateDir ];
    };
  };

  services.collabora-online = {
    enable = true;
    package = collabora2504;
    settings = {
      net.proto = "IPv4";
      net.listen = "loopback";
      ssl.enable = false;
      ssl.termination = true;
      logging.level = "trace";
      storage.wopi.host = "https://wopiserver.home.lan:443";
      net.content_security_policy = "media-src 'self' blob: https://collabora.home.lan; frame-ancestors cloud.home.lan collabora.home.lan wopiserver.home.lan; object-src 'self'; style-src 'self'; script-src 'self' 'unsafe-eval'; frame-ancestors cloud.home.lan collabora.home.lan.* wopiserver.home.lan.*; img-src 'self' data: https://www.collaboraoffice.com cloud.home.lan collabora.home.lan.* wopiserver.home.lan.*; connect-src 'self' wss://collabora.home.lan https://collabora.home.lan; frame-src 'self'; font-src 'self'; default-src 'none';";
    };
  };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "127.0.0.1:5232" ];
      };
      auth = {
        type = "http_x_remote_user";
      };
      web = {
        type = "none";
      };
    };
  };

  services.nginx = {
    virtualHosts = {
      "cloud.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 10M;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          keepalive_timeout 3600s;
          keepalive_requests 100000;
          proxy_next_upstream off;
          http2_max_concurrent_streams 512;
        '';
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9200";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
      "collabora.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 10M;
        '';
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
            '';
          };
          "^~ /browser" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
            '';
          };
          "^~ /hosting/discovery" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
            '';
          };
          "^~ /hosting/capabilities" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''   
              proxy_set_header Host $host;
            '';
          };
          "~ ^/cool/(.*)/ws$" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_read_timeout 36000s;
            '';
          };
          "~ ^/cool" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_read_timeout 36000s;
            '';
          };
          "^~ /cool/adminws" = {
            proxyPass = "http://127.0.0.1:9980";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_read_timeout 36000s;
            '';
          };
        };
      };
      "wopiserver.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9300";
            recommendedProxySettings = false;
            recommendedUwsgiSettings = false;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
  };
}

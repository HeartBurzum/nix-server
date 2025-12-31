{
  config,
  lib,
  pkgs,
  ...
}:
let
  environment = {
    INSECURE = "true";
    PROXY_TLS = "false";
    OC_DOMAIN = "cloud.home.lan";
    OC_URL = "https://cloud.home.lan";
    OC_INSECURE = "false";
    OC_CORS_ALLOW_ORIGINS = "[https://cloud.home.lan]";
    PROXY_LOG_LEVEL = "warn";
    PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";
    COLLABORA_DOMAIN = "collabora.home.lan";
    COLLABORATION_APP_PRODUCT = "Collabora";
    COLLABORATION_APP_NAME = "CollaboraOnline";
    COLLABORATION_WOPI_SRC = "https://wopiserver.home.lan";
    COLLABORATION_APP_INSECURE = "true";
    COLLABORATION_APP_ADDR = "https://collabora.home.lan";
    COLLABORATION_LOG_LEVEL = "trace";
  };

  oc4 = pkgs.callPackage ./opencloud-package.nix { };
in
{
  sops.secrets."opencloud/.env" = {
    owner = config.services.opencloud.user;
  };

  services.opencloud = {
    enable = true;
    package = oc4;
    address = "127.0.0.1";
    url = "https://cloud.home.lan";
    inherit environment;
    environmentFile = "/run/secrets/opencloud/.env";
    settings.csp.directives = {
      child-src = [ "'self'" ];
      connect-src = [
        "'self'"
        "blob:"
        "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
      ];
      default-src = [ "'none'" ];
      font-src = [ "'self'" ];
      frame-ancestors = [
        "'self'"
        "https://cloud.home.lan"
        "https://collabora.home.lan"
        "https://wopiserver.home.lan"
      ];
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
        "'unsafe-eval'"
      ];
      style-src = [
        "'self'"
        "'unsafe-inline'"
      ];
    };
    settings.proxy = builtins.fromJSON (builtins.readFile ./proxy_settings.json);
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

  virtualisation.containers.enable = true;

  users.groups."cool" = { };
  users.users."cool" = {
    enable = true;
    group = "cool";
    isSystemUser = true;
  };

  sops.secrets."collabora/proof_key" = {
    owner = "cool";
    path = "/etc/coolwsd/proof_key";
    mode = "0444";
  };

  environment.etc = {
    "coolwsd/coolwsd.xml" = {
      text = builtins.readFile ./coolwsd.xml;
      mode = "0644";
    };
    "coolwsd/proof_key.pub" = {
      text = builtins.readFile ./proof_key.pub;
      mode = "0644";
    };
  };

  virtualisation.oci-containers.containers = {
    collabora-online = {
      image = "collabora/code:25.04.7.3.1";
      ports = [ "127.0.0.1:9980:9980" ];
      volumes = [
        "/etc/coolwsd/:/etc/coolwsd"
        "/run/secrets/collabora/:/run/secrets/collabora"
      ];
      serviceName = "podman-codewsd";
      privileged = true;
      autoStart = true;
      autoRemoveOnStop = false;
      extraOptions = [
        "--restart=always"
        "--cap-drop=ALL"
      ];
      environment = {
        extra_params = "--o:net.proto=IPV4 --o:net.listen=0.0.0.0 --o:ssl.enable=false --o:ssl.termination=true --o:logging.level=warning --o:storage.wopi.host=https://wopiserver.home.lan";
      };
      capabilities = {
        SYS_CHROOT = true;
        SYS_ADMIN = true;
      };
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
        sslCertificate = "/etc/ssl/certs/lab.home.lan.bundle.pem";
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

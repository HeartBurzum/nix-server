{config, lib, pkgs, ...}:
let
  env_path = "/var/lib/searx";
  redis = (pkgs.redis.override { useSystemJemalloc = false; });
in
{
  sops.secrets."searxng/SEARXNG_SECRET" = { 
    owner = "searx";
    path = "${env_path}/SEARXNG_SECRET";
    restartUnits = [ "searx-init.service" "uwsgi.service" ];
  };

  sops.templates."SEARXNG_SECRET" = {
    owner = "searx";
    content = "${config.sops.placeholder."searxng/SEARXNG_SECRET"}";
  };

  services.uwsgi.instance.vassals.searx.envdir = "${env_path}";

  services.searx = {
    enable = true;
#    redisCreateLocally = true; # crashes with hardened_alloc from using jemalloc, we compile our own redis package
    configureUwsgi = true;
#    environmentFile = "${config.sops.templates."searx.env".path}";
    uwsgiConfig = {
      socket = "/run/searx/searx.sock";
      http = "127.0.0.1:8888";
      chmod-socket = "660";
    };

    settings = {
      general = {
        debug = false;
      };
      server = {
        base_url = "http://search.home.lan";
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key = "a";
        limiter = true;
        public_instance = false;
        image_proxy = true;
        method = "GET";
      };
      outgoing = {
        request_timeout = 5.0;
        max_request_timeout = 15.0;
        pool_connections = 100;
        pool_maxsize = 15;
        enable_http2 = true;
      };
      search = {
        formats = ["html" "json"];
      };
      valkey = {
        url = "unix://${config.services.redis.servers.searx.unixSocket}";
      };
    };
    limiterSettings = {
      botdetection = {
        #x_for = 1;
        ipv4_prefix = 24;
        trusted_proxies = [
          "127.0.0.1/32"
        ];
        iplimit = {
          link_token = true;
        };
      };
      botdetection.ip_lists.pass_ip = [
        "192.168.0.0/24"
      ];
    };
  };

  services.redis = {
    package = redis;
    servers = {
      searx = {
        enable = true;
        user = "searx";
        port = 0;
      };
    };
  };

  systemd.services.nginx.serviceConfig.ProtectHome = false;
  users.groups.searx.members = ["nginx"];

  services.nginx = {    
    virtualHosts = {
      "search.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              uwsgi_pass unix:${config.services.searx.uwsgiConfig.socket};
            '';
          };
        };
      };
    };
  };
}

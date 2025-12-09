{config, ...}:
let
  publicKey = builtins.readFile ./home.lan.cert.pem;
in
{
  security.pki.certificateFiles = [
    ./lab-ca-chain.cert.pem
  ];

  environment.etc = {
    "ssl/certs/home.lan.cert.pem" = {
      text = ''${publicKey}'';
      mode = "0444";
    };
  };

  sops.secrets."nginx/private_key" = {
    owner = config.users.users.nginx.name;
    group = config.users.users.nginx.group;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "zzz3past.myftp.org" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            return = "200 '<html><body>Up!</body></html>'";
            extraConfig = ''
              default_type text/html;
            '';
#            extraConfig = ''   
#              uwsgi_pass unix:${config.services.searx.uwsgiConfig.socket};
#            '';
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "pattod2@gmail.com";
  };
}

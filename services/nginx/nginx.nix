{
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

{config, pkgs, ...}:
let
syncstorage-rs = pkgs.callPackage ./syncstorage-package.nix { };
in
{
  services.firefox-syncserver = {
    enable = true;
    package = syncstorage-rs;
    singleNode = {
      enable = true;
      url = "https://sync.home.lan:443";
    };
    secrets = config.sops.templates."firefox-syncserver".path;
  };

  services.nginx = {
    virtualHosts = {
      "sync.home.lan" = {
        sslCertificate = "/etc/ssl/certs/home.lan.cert.pem";
        sslCertificateKey = config.sops.secrets."nginx/private_key".path;
        forceSSL = true;
        locations = {
          "/" = {
            recommendedProxySettings = true;
            proxyPass = "http://127.0.0.1:5000";
          };
        };
      };
    };
  };

  sops.secrets."firefox-sync/master_secret" = { };
  sops.templates."firefox-syncserver".content = ''
      SYNC_MASTER_SECRET=${config.sops.placeholder."firefox-sync/master_secret"}
  '';
}

{pkgs, config, ...}:
let
  dns-blocklists = pkgs.callPackage ./services/dns-blocklists/dns-blocklists.nix { inherit pkgs; };
in
rec {
  environment.systemPackages = with pkgs; [
    dns-blocklists
  ];

  imports = [
    (import ./services/coredns/coredns.nix { blocklist-path = dns-blocklists; inherit config; })
    ./services/nginx/nginx.nix
    ./services/searxng/searxng.nix
    ./services/grafana/grafana.nix
  ];

  networking.hostName = "lab";
#  networking.domain = "home.lan";

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.age.generateKey = true;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services.mysql = {
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        port = 3306;
        datadir = "/var/lib/mysql";
      };
    };
  };

  services.firefox-syncserver = {
    enable = true;
    singleNode = {
      enable = true;
#      enableTLS = true;
      enableNginx = true;
      hostname = "sync.home.lan";
      url = "http://sync.home.lan:80";
    };
    secrets = config.sops.templates."firefox-syncserver".path;
  };

  sops.secrets."firefox-sync/master_secret" = { };
  sops.templates."firefox-syncserver".content = ''
      SYNC_MASTER_SECRET=${config.sops.placeholder."firefox-sync/master_secret"}
  '';

}

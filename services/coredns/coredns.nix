{blocklist-path, config, ...}:
let
  local-ip = "192.168.3.2";
in
{
  services.coredns = {
    enable = true;
    config = ''
      home.lan:53 {
        prometheus 127.0.0.1:9005
        log
        acl {
          allow net 192.168.0.0/16 10.200.254.0/24
          block
        }
        hosts {
          ${local-ip} cloud.home.lan
          ${local-ip} collabora.home.lan
          ${local-ip} wopiserver.home.lan
          ${local-ip} lab.home.lan
          ${local-ip} photos.home.lan
          ${local-ip} status.home.lan
          ${local-ip} search.home.lan
          ${local-ip} sync.home.lan
          192.168.1.1 fw1.home.lan
          192.168.1.73 desktop.home.lan
        }
      }

      zzz3past.myftp.org {
        log
        acl {
          allow net 192.168.0.0/16 10.200.254.0/24
          block
        }
        hosts {
          ${local-ip} zzz3past.myftp.org
        }
      }

      . {
        prometheus 127.0.0.1:9005
        log
        acl {
          allow net 192.168.0.0/16 10.200.254.0/24
          block
        }
        hosts ${blocklist-path}/hosts/pro-compressed.txt {
          reload 0
          fallthrough
        }
        cache
        forward . 127.0.0.1:5301 127.0.0.1:5302
      }

      .:5301 {
        bind 127.0.0.1
        forward . tls://8.8.8.8 tls://8.8.4.4 {
          tls_servername dns.google
        }
        forward . tls://1.1.1.1 tls://1.0.0.1 {
          tls_servername cloudflare-dns.com
        }
      }

      .:5302 {
        bind 127.0.0.1
        forward . tls://1.1.1.1 tls://1.0.0.1 {
          tls_servername cloudflare-dns.com 
        }
        forward . tls://8.8.8.8 tls://8.8.4.4 {
          tls_servername dns.google
        }
      }
    '';
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}

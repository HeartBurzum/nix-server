{ config, pkgs, ... }:
let
  simple_backup = pkgs.callPackage ./simple_backup-package.nix { };
  pub_key = builtins.readFile ./pubkey.pub;
in
{
  environment.systemPackages = [
    simple_backup
  ];

  environment.etc."gpg_pub/pubkey.pub" = {
    text = "${pub_key}";
    mode = "444";
  };

  systemd.services."simple_backup" = {
    description = "Simple Backup service";
    documentation = [
      "https://github.com/HeartBurzum/simple_backup"
    ];
    environment = {
      SIMPLE_BACKUP_PATH = "${config.services.immich.mediaLocation}:/var/lib/radicale:${config.services.opencloud.stateDir}";
      SIMPLE_BACKUP_DATA_DIR = "/var/lib/simple_backup";
      SIMPLE_BACKUP_NUMBER_COPIES = "3";
      SIMPLE_BACKUP_ENCRYPTION_ENABLE = "True";
      SIMPLE_BACKUP_ENCRYPTION_FINGERPRINTS = "1C77E5C237497F06F47F67107B40AC48BE61CFCF";
      SIMPLE_BACKUP_ENCRYPTION_PUBLIC_KEY_DIR = "/etc/gpg_pub";
      SIMPLE_BACKUP_ENCRYPTION_KEYRING_DIR = "/var/lib/simple_backup/keyring";
      SIMPLE_BACKUP_ENCRYPTION_REMOVE_UNENCRYPTED = "True";
    };
    requires = [
      "multi-user.target"
      "local-fs.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${simple_backup}/bin/simple_backup-run";
      Nice = 10;
    };
    unitConfig = {

    };
  };

  systemd.timers."simple_backup" = {
    timerConfig = {
      OnCalendar = "daily";
    };
    wantedBy = [
      "timers.target"
    ];
  };
}

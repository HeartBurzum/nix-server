{ config, pkgs, ... }:
let
  simple_backup = pkgs.callPackage ./simple_backup-package.nix { };
  pub_key = builtins.readFile ./pubkey.pub;

  # TODO: Make these scripts better, make sure drive is mounted.
  usbBackupMountScript =
    pkgs.resholve.writeScriptBin "usb-auto-backup-mount"
      {
        inputs = with pkgs; [
          coreutils
          util-linux
          systemdMinimal
        ];
        interpreter = "${pkgs.bash}/bin/bash";
        fake = {
          external = [
            "systemd-cat"
            "mount"
          ];
        };
        keep = [
          "${pkgs.coreutils}/bin/mkdir"
          "${pkgs.util-linux}/bin/mount"
          "${pkgs.util-linux}/bin/umount"
        ];
      }
      ''
        name=$(basename "$0")
        exec > >(systemd-cat -t "$name" -p info ) 2> >(systemd-cat -t "$name" -p err )

        id
        groups
        ${pkgs.coreutils}/bin/mkdir -p /run/media
        ${pkgs.util-linux}/bin/mount -v /dev/disk/by-uuid/D5C0-E830 /run/media/D5C0-E830
      '';

  usbBackupCopyScript =
    pkgs.resholve.writeScriptBin "usb-auto-backup-copy"
      {
        inputs = with pkgs; [
          coreutils
          rsync
          systemdMinimal
          util-linux
        ];
        interpreter = "${pkgs.bash}/bin/bash";
        fake = {
          external = [
            "systemd-cat"
          ];
        };
        keep = [
          "${pkgs.rsync}/bin/rsync"
          "${pkgs.util-linux}/bin/umount"
        ];
      }
      ''
        name=$(basename "$0")
        exec > >(systemd-cat -t "$name" -p info ) 2> >(systemd-cat -t "$name" -p err )

        MOUNTDIR=/run/media/D5C0-E830

        if ! [[ -d "$MOUNTDIR" ]]; then
          exit 5
        fi

        echo "start copy"
        ${pkgs.rsync}/bin/rsync -aiv /var/lib/simple_backup/backups/* $MOUNTDIR/
        echo "end copy"
        ${pkgs.util-linux}/bin/umount -v $MOUNTDIR
      '';
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

  systemd.services."usb-auto-backup-mount" = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${usbBackupMountScript}/bin/usb-auto-backup-mount";
    };
  };

  systemd.services."usb-auto-backup-copy" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${usbBackupCopyScript}/bin/usb-auto-backup-copy";
    };
    requires = [
      "usb-auto-backup-mount.service"
    ];
  };

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "99-usb-auto-backup";
      text = ''
        ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_MODEL_ID}=="1006", ENV{ID_VENDOR_ID}=="154b", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.stdenv.shell} -c '${pkgs.systemdMinimal}/bin/systemctl start usb-auto-backup-mount.service'"
        ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_MODEL_ID}=="1006", ENV{ID_VENDOR_ID}=="154b", ENV{ID_FS_USAGE}=="filesystem", TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb-auto-backup-copy.service"
        ACTION=="remove", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_MODEL_ID}=="1006", ENV{ID_VENDOR_ID}=="154b", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.stdenv.shell} -c '${pkgs.systemdMinimal}/bin/systemctl stop usb-auto-backup-mount.service'"
      '';
      destination = "/etc/udev/rules.d/99-usb-auto-backup.rules";
    })
  ];
}

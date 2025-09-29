{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.memoryAllocator.provider = "graphene-hardened-light";

  boot.kernel.sysctl = {
    "fs.binfmt_misc.status" = "0"; # disable arbitrary binary register execution
    "kernel.core_pattern" = "|/bin/false"; # disable writing core dumps
    "kernel.dmesg_restrict" = "1"; # default value in nixos, disable dmesg for users without CAP_SYSLOG
    "kernel.io_uring_disabled" = "2"; # disable io_uring for all processes
    "kernel.kexec_load_disabled" = "1"; # disable kexec after boot
    "kernel.kptr_restrict" = "2"; # disable leaking kernel memory addresses
    "kernel.perf_cpu_time_max_percent" = "1"; # throttle cpu perf sampling to 1% of cpu
    "kernel.perf_event_paranoid" = "2"; # default value in nixos, disable kernel profiling without CAP_PERFMON
    "kernel.printk" = "3 3 1 3"; # only log error or higher kernel messages
    "kernel.randomize_va_space" = "2"; # default value in nixos, enable ASLR
    "kernel.sysrq" = "0"; # disable magic keys
    "kernel.unprivileged_bpf_disabled" = "2"; # default value in nixos, disable unprivileged bpf usage
    "vm.max_map_count" = "1048576"; # default value in nixos but recommended for graphene-hardened
    "vm.mmap_min_addr" = "65536"; # disable mmap calls into lower addresses
    "vm.mmap_rnd_bits" = "32"; # increase the amount of bits used for ASLR randomization
    "vm.mmap_rnd_compat_bits" = "16"; # increase the amount of bits used for ASL randomization for compatibility mode
    "vm.unprivileged_userfaultfd" = "0"; # default in nixos, restrict page fault handling in user space
  };

  sops.secrets."login/pastmaster/password" = {
    neededForUsers = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt # QSV on 11th gen or newer
      intel-media-sdk # QSV up to 11th gen
    ];
  };
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pastmaster = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     hashedPasswordFile = config.sops.secrets."login/pastmaster/password".path;
     packages = with pkgs; [
       tree
     ];
   };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYua/Gy35BUTAarK2SYZgtXltumon1zPtqvRN2pjhrM pastmaster@pastmaster-desktop"
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}


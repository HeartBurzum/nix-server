{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
    ];

  environment.memoryAllocator.provider = "graphene-hardened-light";

  security.lockKernelModules = true; # disable loading kernel modules after boot

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest; # use latest kernel
    blacklistedKernelModules = [
      "ax25"
      "netrom"
      "rose"
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];
    kernelParams = [
      "slab_nomerge" # dont merge slabs of similar size
      "init_on_alloc=1" # zero out allocated pages
      "init_on_free=1" # zero out freed pages
      "page_alloc.shuffle=1" # randomize freed page list
      "randomize_kstack_offset=on" # randomize kernel stack offset
      "debugfs=off" # disable debugfs
      "oops=panic" # always panic kernel on an oops
      "intel_iommu=on" # enable intel iommu
      "iommu=force" # force hardware iommu
      "iommu.strict=1" # DMA unmap invlaidation of TLBs
    ];
    kernel.sysctl = {
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

      # networking
      "net.ipv4.ip_forward" = "0"; # disable packet forwarding on all ipv4 interfaces
      "net.ipv4.conf.all.forwarding" = "0"; # ""
      "net.ipv4.conf.default.forwarding" = "0"; # ""
      "net.ipv4.conf.all.accept_redirects" = "0"; # ignore icmp redirects
      "net.ipv4.conf.default.accept_redirects" = "0"; # ""
      "net.ipv4.conf.all.send_redirects" = "0"; # dont send icmp redirects
      "net.ipv4.conf.default.send_redirects" = "0"; # ""
      "net.ipv4.conf.all.secure_redirects" = "1"; # only accept icmp redirects from listed gateways
      "net.ipv4.conf.default.secure_redirects" = "1"; # ""
      "net.ipv4.conf.all.accept_source_route" = "0"; # disable SSR
      "net.ipv4.conf.default.accept_source_route" = "0"; # ""
      "net.ipv4.conf.all.rp_filter" = "1"; # strict reverse path
      "net.ipv4.conf.default.rp_filter" = "1"; # ""
      "net.ipv4.tcp_dsack" = "0"; # disable duplicate sacks
      "net.ipv4.tcp_rfc1337" = "0"; # disable rfc1337 compliance
      "net.ipv4.tcp_sack" = "0"; # disable select acks
      "net.ipv4.tcp_syncookies" = "1"; # syn flood protection
      "net.ipv4.icmp_ignore_bogus_error_responses" = "1"; # ignore bad icmp responses
      "net.ipv4.conf.all.log_martians" = "1"; # log incorrect destination packets
      "net.ipv4.conf.default.log_martians" = "1"; # ""
      "net.ipv4.conf.all.arp_announce" = "2"; # always use best local address
      "net.ipv4.conf.default.arp_announce" = "2"; # ""
      "net.ipv4.conf.all.arp_ignore" = "1"; # only reply to arp requests if target is local
      "net.ipv4.conf.default.arp_ignore" = "1"; # ""
      "net.ipv4.conf.all.drop_gratuitous_arp" = "1"; # drop all extra arp frames
      "net.ipv4.conf.default.drop_gratuitous_arp" = "1"; # ""
      "net.ipv4.icmp_echo_ignore_broadcasts" = "1"; # ignore icmp multicast
      # disable ipv6 network stack
      "net.ipv6.conf.all.disable_ipv6" = "1";
      "net.ipv6.conf.default.disable_ipv6" = "1";
      "net.ipv6.conf.lo.disable_ipv6" = "1";
    };
  };

  zramSwap.enable = true;

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
#      vaapiVdpau
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt # QSV on 11th gen or newer
#      intel-media-sdk # QSV up to 11th gen
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


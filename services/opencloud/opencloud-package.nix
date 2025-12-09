{ pkgs, ... }:
pkgs.opencloud.overrideAttrs (old: {
  version = "4.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "opencloud-eu";
    repo = "opencloud";
    tag = "v${old.version}";
    hash = "sha256-7yl6jOJZYJjSc48ko973NWTRPjlaVkdM2u8TZ2NfR74=";
  };
  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.String=nixos"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.Tag=4.0.0"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.Date=19700101"
  ];
})

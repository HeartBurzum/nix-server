{ pkgs, ... }:
pkgs.opencloud.overrideAttrs (old: {
  version = "4.0.5";
  src = pkgs.fetchFromGitHub {
    owner = "opencloud-eu";
    repo = "opencloud";
    tag = "v${old.version}";
    hash = "sha256-EseQbzQ/YRdv4b7cMl+563aQN5IcRMIZZtVqf9C4XCw=";
  };
  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.String=nixos"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.Tag=4.0.5"
    "-X"
    "github.com/opencloud-eu/opencloud/pkg/version.Date=19700101"
  ];
})

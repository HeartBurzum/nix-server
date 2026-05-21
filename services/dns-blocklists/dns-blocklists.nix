{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.141.66964";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-XV2iocIZmmEqMmG7mKQTMlxd0k0umdoVqRA5/qHkh1Y=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

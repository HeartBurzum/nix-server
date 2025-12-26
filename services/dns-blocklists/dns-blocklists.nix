{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.360.38987";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-Xxpt7Vv+fAvtIAId9f1qyB60TRCiMZiULHhe1AespfQ=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

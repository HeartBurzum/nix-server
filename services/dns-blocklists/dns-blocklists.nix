{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.128.71279";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-AACOrvO00bbX3XcyGyhhEkW2JZn3JpK0eWsEEOVH7VY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

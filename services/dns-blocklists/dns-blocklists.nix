{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.117.56379";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-CWRnF9PoAsrxN6koVrp+Lt4pPnJLucukgi323UgG1Mc=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

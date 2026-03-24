{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.83.40490";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-25aWjNp8kxGydv77/PQDq61yo8n2BCwrQjxZDtw2F+c=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

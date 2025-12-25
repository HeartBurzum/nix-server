{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.359.9780";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-Xt4jHAP1/uin3ge8SsBQ+ix1KY1B2zrXUS1esreIxiY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

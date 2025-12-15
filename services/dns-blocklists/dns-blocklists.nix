{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.348.54466";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-nNUbEZjeHPQEQ4H+zLSnSdHZC8pJvhtp7Jg/9Ocp7Ws=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

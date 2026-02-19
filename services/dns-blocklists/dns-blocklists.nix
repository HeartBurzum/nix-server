{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.50.39905";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-vMA2ZLomMjhODgFRwgK9XEjA2SkDz0xvGG1taH2N6Xs=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

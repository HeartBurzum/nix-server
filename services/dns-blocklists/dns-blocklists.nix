{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.111.68397";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TBbCJ+Tn6Yua+evOm/jqbV8edVRHZCRXeg8dt4t0aQg=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

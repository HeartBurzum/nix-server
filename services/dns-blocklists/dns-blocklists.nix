{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.263.72053";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-2G4Q1pC+IBgQqp08eSXD23F/rlC52zYb1Yc+pRuhHgo=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

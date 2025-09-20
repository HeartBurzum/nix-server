{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.263.30973";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-Kx65H6OhsycIRavxSWexew0RWdXcpMTnVkP5+JJ7ULE=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

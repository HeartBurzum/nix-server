{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.308.9786";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-PeOQ9CU2upcdi067LiWaAOW5NbL6Vww1nuFZsLuMD/w=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

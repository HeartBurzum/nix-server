{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.300.38639";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-BiH2Yu3mRoS/x8iS71z08GGkh4s5VMM6IZyjhbYrRPs=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

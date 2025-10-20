{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.293.42299";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-AE6WFKeIuQFCeCKCnT5N2rT7S7TiPwaJKuy0pNUBuuw=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

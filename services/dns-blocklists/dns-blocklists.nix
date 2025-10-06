{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.278.85520";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TAlWhSyDUYmG0SXYvtjGtwIoPrse2YHd8raOFTa6jIQ=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

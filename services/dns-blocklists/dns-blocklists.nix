{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.301.38541";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TeUhhyyLlbIP1pbWhWUxV2XLAplgMPGOJOMWa5i/cPs=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

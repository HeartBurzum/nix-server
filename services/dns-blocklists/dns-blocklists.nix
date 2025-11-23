{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.327.52972";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-W6POXrNvHjr3SaT1T3eSuG+iuwSfDsg7dFSUOzIg2g0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

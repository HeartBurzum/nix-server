{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.298.35249";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-kqGUS5lJHuBGQAUwOfZj+rtMMYzk45HdgcNBf/avNCY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

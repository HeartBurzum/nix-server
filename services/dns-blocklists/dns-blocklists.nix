{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.317.53079";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TLAfbeMkqhVriTpECtbLY9gveN8r/IUFJK3/m4OPsu8=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.289.42664";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-OddGUPM6aGZ4b3KqN2iRYrqPIifMKeGvZDNViP6NuKQ=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

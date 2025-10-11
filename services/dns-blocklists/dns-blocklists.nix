{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.284.43304";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-2Udb2TzQjRHEHsfCd/faIeKj2C4U1ChVG69/r2qy93o=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

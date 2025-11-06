{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.310.67296";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-oHPFPIGfSHLyso7Gak2j7cEl+LI95FhVZ6i4fLFdiD8=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

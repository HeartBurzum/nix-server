{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.299.38338";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-DUJvk78p19/OLtxJ2zfVIUmOWFcDFCv06W6cOw4D6ag=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

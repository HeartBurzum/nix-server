{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.320.53043";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-cXeh0Y3Wy6NUoBuiXANNgE3TTusCqC/5GXvHVaV6bTY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

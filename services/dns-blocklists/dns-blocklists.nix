{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.285.43267";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-f1Yc3+jCz6ocJSx9vDgZPyzQAyY4wzpL1u7ghpniyF0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.338.67547";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-5uBjhHKmtJ70Oj8KrV+VEBN7YYm4xqaANvqU3EDVajU=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

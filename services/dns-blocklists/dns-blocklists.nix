{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.306.39251";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-8Zp4WYIP+/RhH8QyAdGtF3l+Er/UMeNu+MJmeJh1pqU=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

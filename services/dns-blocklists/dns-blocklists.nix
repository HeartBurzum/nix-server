{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.311.41543";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-LA0bp/hNOdAd8mBmSWtCCLOTPIkAh7dojIv5XlwrcZ0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

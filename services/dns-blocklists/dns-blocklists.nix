{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.269.307";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TLRs8XewkPfgNSHunFYgOhNFPejuF9nYumouZNPa4gA=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}

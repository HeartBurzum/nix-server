{ python3, fetchFromGitHub }:
python3.pkgs.buildPythonApplication rec {
  pname = "simple_backup";
  version = "0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "HeartBurzum";
    repo = "simple_backup";
    rev = "c2c9fe1301e1a49b32eb1070802bf965dcf36ffc";
    hash = "sha256-4k9e+MezE5bta/ofUiybSRQS9nvpUe2Vsy79mK1Wz1A=";
  };

  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [
    python-gnupg
  ];

  meta = {

  };
}

{pkgs}:
pkgs.python313Packages.buildPythonPackage rec {
  pname = "llm-openrouter";
  version = "0.4.1";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "simonw";
    repo = "llm-openrouter";
    rev = version;
    sha256 = "sha256-ojBkyXqEaqTcOv7mzTWL5Ihhb50zeVzeQZNA6DySuVg=";
  };

  propagatedBuildInputs = with pkgs.python313Packages; [llm];
}

{
  lib,
  python313,
  fetchFromGitHub,
}:
python313.pkgs.buildPythonPackage rec {
  pname = "mlx-lm";
  version = "0.24.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ml-explore";
    repo = "mlx-lm";
    rev = "v${version}";
    hash = "sha256-d//JUhvRpNde1+drWWYJ9lmkXi+buaa1zxDg4rQdt0o=";
  };

  build-system = [
    python313.pkgs.setuptools
    python313.pkgs.wheel
  ];

  dependencies = with python313.pkgs; [
    jinja2
    mlx
    numpy
    protobuf
    pyyaml
    transformers
  ];

  pythonImportsCheck = [
    "mlx_lm"
  ];

  meta = {
    description = "Run LLMs with MLX";
    homepage = "https://github.com/ml-explore/mlx-lm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
    mainProgram = "mlx-lm";
  };
}

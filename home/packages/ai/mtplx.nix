{pkgs, ...}: let
  mtplx = pkgs.python3Packages.buildPythonApplication rec {
    pname = "mtplx";
    version = "2.8.2";
    format = "wheel";

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      sha256 = "sha256-dDXq6+u0GSSJEWnCU0XyTBeThmEHaTaNCn8VpqxWd3E=";
    };

    # nixpkgs ships transformers 5.15.0, mtplx pins <5.15.
    pythonRelaxDeps = ["transformers"];

    dependencies = with pkgs.python3Packages; [
      fastapi
      huggingface-hub
      llguidance
      mlx
      mlx-lm
      nanobind
      numpy
      pillow
      pydantic
      rich
      safetensors
      transformers
      uvicorn
    ];

    pythonImportsCheck = ["mtplx"];

    meta = {
      description = "Native MTP speculative decoding for MLX on Apple Silicon";
      homepage = "https://github.com/youssofal/MTPLX";
      mainProgram = "mtplx";
    };
  };
in {
  home.packages = [mtplx];
}

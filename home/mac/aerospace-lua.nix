{
  lib,
  fetchFromGitHub,
  lua54Packages,
  # readline,
}:
lua54Packages.buildLuaPackage {
  pname = "aerospace-lua";
  version = "unstable-2025-05-08";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "AeroSpaceLua";
    rev = "58614175340ad6b867fc5303230240fc4d2687ba";
    hash = "sha256-/qqSQhA7qUKrPBrYupexbjOF5/rcY06dsImIcDxog6E=";
  };

  # nativeBuildInputs = [ gcc ];

  # buildInputs = [ readline ];

  makeFlags = ["INSTALL_DIR=$(out)/lib/lua/${lua54Packages.lua.luaversion}"];

  meta = {
    description = "A lua client for the aerospace server to reduce latency when interfacing from sketchybar";
    homepage = "https://github.com/acsandmann/AeroSpaceLua";
    license = lib.licenses.mit;
    maintainers = [];
    # mainProgram = "aero-space-lua";
    platforms = lib.platforms.all;
  };
}

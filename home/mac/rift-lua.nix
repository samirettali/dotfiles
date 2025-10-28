{
  lib,
  fetchFromGitHub,
  lua54Packages,
  readline,
  gcc,
}:
lua54Packages.buildLuaPackage {
  pname = "rift";
  version = "ec555e8294d87aa7aaf5e869471ab4e1912a8186";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift.lua";
    rev = "ba2d42af96f66d1343f9d4b963ec0199e170f4ab";
    hash = "sha256-idjdSfAid3DmRd2i2dRtPlcI87vQo/Dg6Rgd3+In/k8=";
  };

  nativeBuildInputs = [gcc readline];

  # buildInputs = [ readline ];

  makeFlags = ["INSTALL_DIR=$(out)/lib/lua/${lua54Packages.lua.luaversion}"];

  meta = {
    description = "lua client for rift-wm ";
    homepage = "https://github.com/acsandmann/rift.lua";
    license = lib.licenses.mit;
    maintainers = [];
    # mainProgram = "aero-space-lua";
    platforms = lib.platforms.all;
  };
}

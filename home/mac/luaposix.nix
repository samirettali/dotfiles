{
  # bit32,
  buildLuarocksPackage,
  fetchurl,
  fetchzip,
  # luaAtLeast,
  # luaOlder,
}:
buildLuarocksPackage {
  pname = "luaposix";
  version = "36.3";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/luaposix-36.3-1.rockspec";
      sha256 = "sha256-6/sAsOWrrXjdzPlAp/Z5FetQfzrkrf6TmOz3FZaBiks=";
    }).outPath;
  src = fetchzip {
    url = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
    sha256 = "sha256-9KeNjvVJ4lKmqVHW2JjQrOKtYMPkBEkVFan7ZBjKwyA=";
  };

  # disabled = luaOlder "5.1" || luaAtLeast "5.4";
  # propagatedBuildInputs = [bit32];

  postPatch = ''
    substituteInPlace ext/posix/unistd.c --replace 'lua_objlen' 'lua_rawlen'
  '';

  meta = {
    homepage = "https://github.com/luaposix/luaposix/";
    description = "Lua bindings for POSIX";
    # maintainers = with lib.maintainers; [
    #   vyp
    #   lblasc
    # ];
    license.fullName = "MIT/X11";
  };
}

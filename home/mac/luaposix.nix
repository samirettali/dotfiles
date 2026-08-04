{
  buildLuarocksPackage,
  fetchurl,
  fetchzip,
  runCommand,
}:
buildLuarocksPackage {
  pname = "luaposix";
  version = "36.3";
  # upstream rockspec caps lua at < 5.5, but sbarlua is built against 5.5
  knownRockspec =
    runCommand "luaposix-36.3-1.rockspec" {
      src = fetchurl {
        url = "mirror://luarocks/luaposix-36.3-1.rockspec";
        sha256 = "sha256-6/sAsOWrrXjdzPlAp/Z5FetQfzrkrf6TmOz3FZaBiks=";
      };
    } ''
      substitute "$src" "$out" --replace-fail 'lua >= 5.1, < 5.5' 'lua >= 5.1'
    '';
  src = fetchzip {
    url = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
    sha256 = "sha256-9KeNjvVJ4lKmqVHW2JjQrOKtYMPkBEkVFan7ZBjKwyA=";
  };

  postPatch = ''
    substituteInPlace ext/posix/unistd.c --replace-fail 'lua_objlen' 'lua_rawlen'
  '';

  meta = {
    homepage = "https://github.com/luaposix/luaposix/";
    description = "Lua bindings for POSIX";
    license.fullName = "MIT/X11";
  };
}

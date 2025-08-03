{
  # bit32,
  buildLuarocksPackage,
  fetchurl,
  fetchzip,
  # luaAtLeast,
  # luaOlder,
}:
buildLuarocksPackage {
  pname = "luasimdjson";
  version = "0.0.7";
  knownRockspec =
    (fetchurl {
      url = "mirror://luarocks/lua-simdjson-0.0.7-1.rockspec";
      sha256 = "sha256-XxIX5ewzczSD85Ebu6a9ukRMXE3kvveHhrlAWC1BLo8=";
    }).outPath;
  src = fetchzip {
    url = "https://github.com/FourierTransformer/lua-simdjson/archive/0.0.7.zip";
    sha256 = "sha256-WI39Ti+vX+HgDPuedMh31722xlrx+DadDjVKg2HiIjM=";
  };

  # disabled = luaOlder "5.1" || luaAtLeast "5.4";
  # propagatedBuildInputs = [bit32];

  meta = {
    homepage = "https://github.com/FourierTransformer/lua-simdjson/";
    description = " simdjson bindings for lua ";
    # maintainers = with lib.maintainers; [
    #   vyp
    #   lblasc
    # ];
    license.fullName = "Apache-2.0";
  };
}

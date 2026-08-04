{
  buildLuarocksPackage,
  fetchurl,
  fetchzip,
  runCommand,
}:
buildLuarocksPackage {
  pname = "luasimdjson";
  version = "0.0.7";
  # upstream rockspec caps lua at < 5.5, but sbarlua is built against 5.5
  knownRockspec =
    runCommand "lua-simdjson-0.0.7-1.rockspec" {
      src = fetchurl {
        url = "mirror://luarocks/lua-simdjson-0.0.7-1.rockspec";
        sha256 = "sha256-XxIX5ewzczSD85Ebu6a9ukRMXE3kvveHhrlAWC1BLo8=";
      };
    } ''
      substitute "$src" "$out" --replace-fail 'lua >= 5.1, < 5.5' 'lua >= 5.1'
    '';
  src = fetchzip {
    url = "https://github.com/FourierTransformer/lua-simdjson/archive/0.0.7.zip";
    sha256 = "sha256-WI39Ti+vX+HgDPuedMh31722xlrx+DadDjVKg2HiIjM=";
  };

  meta = {
    homepage = "https://github.com/FourierTransformer/lua-simdjson/";
    description = "simdjson bindings for lua";
    license.fullName = "Apache-2.0";
  };
}

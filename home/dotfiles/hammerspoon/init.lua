local hs = hs -- TODO: check if this is needed

if hs.fs.attributes("playground.lua") then
	require("playground")
end

require("bindings")
require("hammerspoon_config")
require("clipboard").start()
require("recursive_binder")
pcall(require, "sketchybar")

-- generates type annotations for the whole hs API into ~/.hammerspoon/annotations,
-- which lua_ls reads; loadSpoon calls its init() itself
hs.loadSpoon("EmmyLua")
hs.loadSpoon("ControlEscape"):start()

hs.alert.show("Hammerspoon loaded")

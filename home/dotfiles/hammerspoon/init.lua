local hs = hs -- TODO: check if this is needed

require("bindings")
require("hammerspoon_config")
require("recursive_binder")

-- hs.loadSpoon("EmmyLua"):init() -- TODO: clone
hs.loadSpoon("ControlEscape"):start()

if hs.fs.attributes("playground.lua") then
	require("playground")
end

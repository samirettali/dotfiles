local hs = hs -- TODO: check if this is needed

if hs.fs.attributes("playground.lua") then
	require("playground")
end

require("bindings")
require("hammerspoon_config")
require("recursive_binder")

-- hs.loadSpoon("EmmyLua"):init() -- TODO: clone
hs.loadSpoon("ControlEscape"):start()

seal = hs.loadSpoon("Seal")
seal:loadPlugins({ "apps", "calc", "screencapture", "useractions" })
seal:refreshAllCommands()
seal:bindHotkeys({
	show = { { "alt" }, "space" },
})
seal:start()

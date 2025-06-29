local hs = hs -- TODO: check if this is needed

require("reload")
require("bindings")
require("hammerspoon_config")
require("disable_keyboard")
require("disable_shortcuts")

-- hs.loadSpoon("EmmyLua"):init() -- TODO: clone
hs.loadSpoon("ControlEscape"):start()

if hs.fs.attributes("playground.lua") then
	require("playground")
end

local SkyRocket = hs.loadSpoon("SkyRocket")
sky = SkyRocket:new({
	resizeModifiers = { "cmd", "ctrl" },
	resizeMouseButton = "right",
	focusWindowOnClick = true,
})

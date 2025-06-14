local hs = hs -- TODO: check if this is needed

require("reload")
require("bindings")
require("hammerspoon_config")
require("disable_keyboard")
require("disable_shortcuts")
pcall(require("playground"))

hs.loadSpoon("EmmyLua"):init()
hs.loadSpoon("ControlEscape"):start()

hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
	"hammerflow.toml",
})

local SkyRocket = hs.loadSpoon("SkyRocket")
sky = SkyRocket:new({
	moveModifiers = { "alt" },
	moveMouseButton = "left",
	resizeModifiers = { "alt" },
	resizeMouseButton = "right",
	focusWindowOnClick = true,
})

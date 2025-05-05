require("monitors")
require("reload")

hs.loadSpoon("ControlEscape"):start()
hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
	"hammerflow.toml",
})

-- hack to disable cmd+m
function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)

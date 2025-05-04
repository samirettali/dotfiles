require("monitors")
require("reload")

hs.loadSpoon("ControlEscape"):start()
hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
	"hammerflow.toml",
})

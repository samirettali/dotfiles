local lib = require("lib")
require("reload")

if lib.file_exists("playground.lua") then
	require("playground")
end

local function merge_tables(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				merge_tables(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

local alertStyle = {
	strokeWidth = 4,
	strokeColor = { white = 0.9, alpha = 0.9 },
	fillColor = { white = 0, alpha = 1 },
	textColor = { white = 0.9 },
	textFont = "JetBrainsMono Nerd Font",
	textSize = 20,
	padding = 20,
	radius = 24,
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

hs.alert.defaultStyle = merge_tables(hs.alert.defaultStyle, alertStyle)

hs.loadSpoon("ControlEscape"):start()
hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
	"hammerflow.toml",
})

-- hack to disable cmd+m
local function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)

hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
	"hammerflow.toml",
})

local function runSystemCommand(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	hs.alert.show(result)
	handle:close()
	return result
end

local function unixTimestamp()
	return hs.eventTap.keyStrokes(runSystemCommand("date +%s"))
end

local function uuid()
	return hs.eventtap.keyStrokes(runSystemCommand("uuidgen"))
end

spoon.Hammerflow.registerFunctions({ ["unixtime"] = unixTimestamp }, { ["uuid"] = uuid })

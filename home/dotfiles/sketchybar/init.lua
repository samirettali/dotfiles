local Rift = require("rift_client")

local rift_success, rift = pcall(Rift.new) -- connects to rift via mach ports

sbar = require("sketchybar")

if rift_success then
	while not rift:is_connected() do
		os.execute("sleep 0.1") -- wait for connection
	end

	sbar.rift = rift
end

local cjson = require("cjson")
D = function(data)
	local message = cjson.encode(data)
	sbar.exec("echo " .. message .. " >> /tmp/debug.log")
end

sbar.begin_config()

require("bar")
require("items")

sbar.hotload(true)
sbar.end_config()

sbar.event_loop()

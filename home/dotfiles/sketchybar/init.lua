local Aerospace = require("aerospace")

local aerospace = Aerospace.new() -- it finds the socket on its own
while not aerospace:is_initialized() do
	os.execute("sleep 0.1") -- wait for connection, not the best workaround
end

sbar = require("sketchybar")
sbar.aerospace = aerospace

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

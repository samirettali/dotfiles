sbar = require("sketchybar")

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

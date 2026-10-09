local separator = require("separator")

-- The items that show only when something needs you (unread mail, pending
-- agents, provider incidents) sit on the left after the front app, behind one
-- separator that shows while any of them does.
local alerts = {}

local shown = {}
local rule

local function update()
	if rule then
		rule:set({ drawing = next(shown) ~= nil })
	end
end

-- Call between the front app and the alert items.
function alerts.add_separator()
	rule = separator.add("alerts", nil, "left")
	update()
end

function alerts.show(name, visible)
	shown[name] = visible or nil
	update()
end

return alerts

local separator = require("separator")

-- The items that show only when something needs you (provider incidents,
-- pending agents, unread mail) sit left of the Claude usage, behind one
-- separator that shows while any of them does.
local alerts = {}

local shown = {}
local rule

local function update()
	if rule then
		rule:set({ drawing = next(shown) ~= nil })
	end
end

-- Call between the usage and the alert items: right-side items render in
-- creation order, rightmost first.
function alerts.add_separator()
	rule = separator.add("alerts")
	update()
end

function alerts.show(name, visible)
	shown[name] = visible or nil
	update()
end

return alerts

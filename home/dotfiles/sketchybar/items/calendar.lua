local icons = require("icons")
local colors = require("colors")

local cal = sbar.add("item", {
	position = "right",
	update_freq = 1,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	local date = os.date("%a %d")
	local time = os.date("%H:%M:%S")
	local label = ("%s - %s"):format(date, time)

	local item = {
		icon = {
			string = icons.clock,
		},
		label = {
			string = label,
		},
	}

	cal:set(item)
end)

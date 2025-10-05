local icons = require("icons")

local timezones = {
	{ name = "NYC", tz = "America/New_York" },
	{ name = "LA", tz = "America/Los_Angeles" },
}

local timezone_items = {}

for _, tz in ipairs(timezones) do
	local item = sbar.add("item", {
		position = "right",
		update_freq = 1,
	})

	item:subscribe({ "forced", "routine", "system_woke" }, function(_)
		local time_cmd = string.format('TZ="%s" date "+%%H:%%M"', tz.tz)
		sbar.exec(time_cmd, function(time_result)
			local time = time_result:gsub("%s+", "")
			local label = string.format("%s %s", tz.name, time)

			item:set({
				icon = {
					string = icons.clock,
				},
				label = {
					string = label,
				},
			})
		end)
	end)

	table.insert(timezone_items, item)
end

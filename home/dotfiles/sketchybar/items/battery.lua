local colors = require("colors")
local icons = require("icons")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 180,
	label = { drawing = false },
	popup = {
		align = "right",
		background = {
			color = colors.black,
			border_color = colors.grey,
			border_width = 1,
			corner_radius = 6,
			padding_left = 6,
			padding_right = 6,
		},
	},
})

local detail = sbar.add("item", "widgets.battery.detail", {
	position = "popup.widgets.battery",
	icon = { drawing = false },
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local found, _, charge = batt_info:find("(%d+)%%")
		if not found then
			return
		end

		charge = tonumber(charge)
		local status = batt_info:match("%%; ([^;]+);") or "unknown"
		local charging = status == "charging" or status == "finishing charge"
		local charged = status == "charged"
		local icon
		local color

		if charging then
			icon = icons.battery.charging
			color = colors.green
		elseif charged then
			icon = icons.battery._100
			color = colors.green
		elseif charge > 80 then
			icon = icons.battery._100
			color = colors.white
		elseif charge > 60 then
			icon = icons.battery._75
			color = colors.white
		elseif charge > 40 then
			icon = icons.battery._50
			color = colors.white
		elseif charge > 20 then
			icon = icons.battery._25
			color = colors.yellow
		else
			icon = icons.battery._0
			color = colors.red
		end

		local state = charging and "Charging" or charged and "Charged" or "On battery"
		battery:set({ icon = { string = icon, color = color } })
		detail:set({ label = { string = ("%s · %d%%"):format(state, charge) } })
	end)
end)

battery:subscribe("mouse.clicked", function()
	local current = battery:query()
	local open = current and current.popup and current.popup.drawing == "on"
	battery:set({ popup = { drawing = not open } })
end)

battery:subscribe("mouse.exited.global", function()
	battery:set({ popup = { drawing = false } })
end)

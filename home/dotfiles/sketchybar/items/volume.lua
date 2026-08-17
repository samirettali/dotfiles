local colors = require("colors")
local icons = require("icons")

local volume = sbar.add("item", "widgets.volume", {
	position = "right",
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

local detail = sbar.add("item", "widgets.volume.detail", {
	position = "popup.widgets.volume",
	icon = { drawing = false },
})

volume:subscribe("volume_change", function(env)
	local level = tonumber(env.INFO)
	if not level then
		return
	end

	local icon = icons.volume._0
	if level > 60 then
		icon = icons.volume._100
	elseif level > 30 then
		icon = icons.volume._66
	elseif level > 10 then
		icon = icons.volume._33
	elseif level > 0 then
		icon = icons.volume._10
	end

	volume:set({
		icon = {
			string = icon,
			color = level == 0 and colors.grey70 or colors.white,
		},
	})
	detail:set({ label = { string = ("%s · %d%%"):format(level == 0 and "Muted" or "Volume", level) } })
end)

volume:subscribe("mouse.clicked", function()
	local current = volume:query()
	local open = current and current.popup and current.popup.drawing == "on"
	volume:set({ popup = { drawing = not open } })
end)

volume:subscribe("mouse.exited.global", function()
	volume:set({ popup = { drawing = false } })
end)

volume:subscribe("mouse.scrolled", function(env)
	local delta = env.INFO.delta
	if env.INFO.modifier ~= "ctrl" then
		delta = delta * 10.0
	end

	local command = ('osascript -e "set volume output volume (output volume of (get volume settings) + %s)"'):format(
		delta
	)
	sbar.exec(command)
end)

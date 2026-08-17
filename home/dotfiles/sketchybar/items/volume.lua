local colors = require("colors")
local icons = require("icons")
local popup = require("popup")

local volume = sbar.add("item", "widgets.volume", {
	position = "right",
	icon = { width = 16, align = "center" },
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

local function update(level, muted)
	local icon = icons.volume._0
	if not muted and level > 60 then
		icon = icons.volume._100
	elseif not muted and level > 30 then
		icon = icons.volume._66
	elseif not muted and level > 10 then
		icon = icons.volume._33
	elseif not muted and level > 0 then
		icon = icons.volume._10
	end

	volume:set({
		icon = {
			string = icon,
			color = muted and colors.grey70 or colors.white,
		},
	})
	detail:set({ label = { string = ("%s · %d%%"):format(muted and "Muted" or "Volume", level) } })
end

volume:subscribe("volume_change", function()
	sbar.exec("osascript -e 'get volume settings'", function(settings)
		local level = tonumber(settings:match("output volume:(%d+)"))
		local muted = settings:match("output muted:(%a+)")
		if level and muted then
			update(level, muted == "true")
		end
	end)
end)

popup.setup(volume)

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

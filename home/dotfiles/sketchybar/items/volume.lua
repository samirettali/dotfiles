local colors = require("colors")
local icons = require("icons")
local popup = require("popup")

local volume = sbar.add("item", "widgets.volume", {
	position = "right",
	padding_left = 6,
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

-- The popup slider both reports the level and sets it, so the popup needs no
-- separate line of text.
local detail = sbar.add("slider", "widgets.volume.detail", 120, {
	position = "popup.widgets.volume",
	icon = { drawing = false },
	label = { align = "right", width = 44, padding_left = 6 },
	slider = {
		highlight_color = colors.white,
		background = {
			color = colors.grey23,
			height = 10,
			corner_radius = 2,
		},
		knob = { drawing = false },
	},
})

-- A slider click arrives as PERCENTAGE, not inside INFO.
detail:subscribe("mouse.clicked", function(env)
	local percentage = tonumber(env.PERCENTAGE)
	if not percentage then
		return
	end
	sbar.exec(("osascript -e 'set volume output volume %d'"):format(percentage))
end)

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
	detail:set({
		slider = {
			percentage = level,
			highlight_color = muted and colors.grey50 or colors.white,
		},
		label = {
			string = muted and "Muted" or ("%d%%"):format(level),
			color = muted and colors.grey70 or colors.white,
		},
	})
end

local function query()
	sbar.exec("osascript -e 'get volume settings'", function(settings)
		local level = tonumber(settings:match("output volume:(%d+)"))
		local muted = settings:match("output muted:(%a+)")
		if level and muted then
			update(level, muted == "true")
		end
	end)
end

volume:subscribe("volume_change", query)

popup.setup(volume, query)
query()

local function scroll(env)
	local delta = env.INFO.delta
	if env.INFO.modifier ~= "ctrl" then
		delta = delta * 10.0
	end

	local command = ('osascript -e "set volume output volume (output volume of (get volume settings) + %s)"'):format(
		delta
	)
	sbar.exec(command)
end

volume:subscribe("mouse.scrolled", scroll)
-- Sketchybar reports a slider once per click, never during the drag, so the
-- wheel is what gives continuous feedback: each step fires volume_change and
-- the bar redraws itself.
detail:subscribe("mouse.scrolled", scroll)

local icons = require("icons")

local volume_percent = sbar.add("item", {
	position = "right",
})

volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end
	label = ("%s%%"):format(volume)

	volume_percent:set({ icon = icon, label = label })
end)

local function volume_scroll(env)
	local delta = env.INFO.delta
	if not (env.INFO.modifier == "ctrl") then
		delta = delta * 10.0
	end

	local command = ('osascript -e "set volume output volume (output volume of (get volume settings) + %s)"'):format(
		delta
	)

	sbar.exec(command)
end

volume_percent:subscribe("mouse.scrolled", volume_scroll)

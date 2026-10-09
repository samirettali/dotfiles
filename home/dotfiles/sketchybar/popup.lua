local colors = require("colors")

local popup = {}

-- One style for every popup and slider, so an edit cannot leave them apart.
local style = {
	align = "right",
	background = {
		color = colors.black,
		border_color = colors.grey,
		border_width = 1,
		corner_radius = 6,
		padding_left = 6,
		padding_right = 6,
	},
}

popup.slider = {
	highlight_color = colors.white,
	background = {
		color = colors.grey23,
		height = 10,
		corner_radius = 2,
	},
	knob = { drawing = false },
}

sbar.add("event", "popup_opened")

-- `align` defaults to right; an item on the left side wants left, or its popup
-- runs off the screen.
function popup.setup(item, on_open, align)
	item:set({ popup = style })
	if align then
		item:set({ popup = { align = align } })
	end

	local function close()
		item:set({ popup = { drawing = false } })
	end

	item:subscribe("popup_opened", function(env)
		if env.POPUP ~= item.name then
			close()
		end
	end)

	local function toggle()
		local current = item:query()
		local open = current and current.popup and current.popup.drawing == "on"
		if open then
			close()
			return
		end

		sbar.trigger("popup_opened", { POPUP = item.name })
		if on_open then
			on_open()
		end
		item:set({ popup = { drawing = true } })
	end

	item:subscribe("mouse.clicked", toggle)
	item:subscribe("mouse.exited.global", close)
	return toggle
end

return popup

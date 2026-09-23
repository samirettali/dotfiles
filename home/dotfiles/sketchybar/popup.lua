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

function popup.setup(item, on_open)
	item:set({ popup = style })

	local function close()
		item:set({ popup = { drawing = false } })
	end

	item:subscribe("popup_opened", function(env)
		if env.POPUP ~= item.name then
			close()
		end
	end)

	item:subscribe("mouse.clicked", function()
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
	end)

	item:subscribe("mouse.exited.global", close)
end

return popup

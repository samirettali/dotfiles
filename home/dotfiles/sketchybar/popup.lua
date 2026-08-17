local popup = {}

sbar.add("event", "popup_opened")

function popup.setup(item, on_open)
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

local cal = sbar.add("item", {
	position = "right",
	update_freq = 1,
	icon = { drawing = false },
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(_)
	local date = os.date("%a %d")
	local time = os.date("%H:%M:%S")
	local label = ("%s - %s"):format(date, time)

	local item = {
		label = {
			string = label,
		},
	}

	cal:set(item)
end)

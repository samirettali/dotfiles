local front_app = sbar.add("item", "front_app", {
	position = "left",
	display = "active",
	icon = { drawing = false },
	updates = true,
	padding_left = 2,
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({ label = { string = env.INFO } })
end)

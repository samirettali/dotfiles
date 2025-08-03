sbar.add("event", "crypto_price_change")

local item = sbar.add("item", "crypto_price", {
	position = "right",
})

item:subscribe("crypto_price_change", function(env)
	sbar.set("crypto_price", {
		icon = {
			drawing = false,
		},
		label = {
			string = env.VALUE,
		},
	})
end)

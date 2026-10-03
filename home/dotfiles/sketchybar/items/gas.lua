local colors = require("colors")
local icons = require("icons")
local separator = require("separator")

-- Ethereum mainnet base fee in gwei. Clicking opens Etherscan's gas tracker.
--
-- The fee is pushed by `gas-sketchybar`, a launchd agent holding an Infura
-- `newHeads` subscription open, which triggers `gas_price` on every block.
-- While the subscription is down the last fee turns grey, and so it does on
-- wake until the next block proves the socket alive. Nothing here polls.
sbar.add("event", "gas_price")

local gas = sbar.add("item", "gas", {
	position = "right",
	drawing = false,
	updates = "on",
	icon = { string = icons.gas },
	click_script = "/usr/bin/open 'https://etherscan.io/gastracker'",
})

-- Created after the item, so it sits on its left. It follows the item's
-- visibility, which keeps a hidden fee from leaving two separators side by side.
local gas_separator = separator.add("gas")
gas_separator:set({ drawing = false })

gas:subscribe("gas_price", function(env)
	local stale = env.stale == "1"
	local color = stale and colors.grey70 or colors.white
	local visible = env.gwei ~= nil and env.gwei ~= ""
	gas_separator:set({ drawing = visible })
	gas:set({
		drawing = visible,
		icon = { color = stale and colors.grey70 or colors.ethereum },
		label = { string = env.gwei, color = color },
	})
end)

-- The watcher notices a socket that died in sleep only up to a minute after
-- wake, so the fee greys out here until the next block arrives.
gas:subscribe("system_woke", function()
	gas:set({ icon = { color = colors.grey70 }, label = { color = colors.grey70 } })
end)

if true then
	return {}
end

return {
	"monkoose/neocodeium",
	event = "VeryLazy",
	config = function()
		local neocodeium = require("neocodeium")

		local opts = {
			show_label = false,
		}

		neocodeium.setup(opts)

		vim.keymap.set("i", "<C-f>", function()
			neocodeium.accept()
		end)
		vim.keymap.set("i", "<C-e>", function()
			neocodeium.cycle_or_complete()
		end)
		vim.keymap.set("i", "<C-y>", function()
			neocodeium.cycle_or_complete(-1)
		end)

		vim.keymap.set("i", "<C-c>", function()
			require("neocodeium").clear()
		end)
	end,
}

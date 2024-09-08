return {
	"Wansmer/symbol-usage.nvim",
	config = function()
		local usage = require("symbol-usage")
		usage.setup()

		vim.keymap.set("n", "<leader>tu", usage.toggle_globally)
	end,
}

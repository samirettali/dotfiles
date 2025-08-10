return {
	"echasnovski/mini.notify",
	version = false,
	event = "VeryLazy",
	opts = {
		window = {
			winblend = 0,
		},
	},
	config = function(_, opts)
		local notify = require("mini.notify")
		notify.setup(opts)

		vim.notify = notify.make_notify()
	end,
}

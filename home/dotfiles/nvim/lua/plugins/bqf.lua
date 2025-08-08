return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		preview = {
			auto_preview = false,
			win_height = 25,
			show_scroll_bar = false,
		},
	},
	init = function()
		vim.fn.sign_define("BqfSign", { text = " ", texthl = "BqfSign" })
	end,
}

return {
	"supermaven-inc/supermaven-nvim",
	opts = {
		log_level = "info",
		keymaps = {
			accept_suggestion = "<C-f>",
			clear_suggestion = "<C-]>",
			accept_word = "<C-j>",
		},
		condition = function()
			return string.match(vim.fn.expand("%:t"), ".envrc")
		end,
	},
}

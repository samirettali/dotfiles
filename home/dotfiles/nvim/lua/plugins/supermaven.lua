return {
	"supermaven-inc/supermaven-nvim",
	opts = {
		log_level = "off",
		accept_suggestion = "<C-f>",
		condition = function()
			return string.match(vim.fn.expand("%:t"), ".envrc")
		end,
	},
}

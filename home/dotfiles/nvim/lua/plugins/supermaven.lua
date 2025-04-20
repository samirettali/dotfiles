return {
	"supermaven-inc/supermaven-nvim",
	opts = {
		log_level = "off",
		keymaps = {
			accept_suggestion = "<C-f>",
			clear_suggestion = "<C-]>",
			accept_word = "<C-j>",
		},
		ignore_filetypes = {
			[".envrc"] = true,
			[".env"] = true,
		},
	},
}

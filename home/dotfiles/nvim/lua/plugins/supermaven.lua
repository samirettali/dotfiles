if true then
	return {}
end

return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	opts = {
		keymaps = {
			accept_suggestion = "<C-f>",
			clear_suggestion = "<C-]>",
			-- accept_word = "<c-j>",
		},
		disable_inline_completion = false,
		disable_keymaps = false,
		log_level = "off",
	},
}

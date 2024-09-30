return {
	"code-biscuits/nvim-biscuits",
	config = function()
		local opts = {
			default_config = {
				prefix_string = "^",
				toggle_keybind = "<leader>ts",
				cursor_line_only = true,
			},
		}

		require("nvim-biscuits").setup(opts)
	end,
}

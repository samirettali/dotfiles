return {
	"code-biscuits/nvim-biscuits",
	config = function()
		require("nvim-biscuits").setup({
			default_config = {
				prefix_string = "^",
				toggle_keybind = "<leader>ts",
			},
		})
	end,
}

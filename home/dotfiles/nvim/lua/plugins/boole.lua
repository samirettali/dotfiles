return {
	"nat-418/boole.nvim",
	setup = function()
		require("boole").setup({
			mappings = {
				increment = "<C-'>",
				decrement = "<C-;>",
			},
		})
	end,
}

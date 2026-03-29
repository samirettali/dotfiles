vim.pack.add({
	-- "https://github.com/wurli/split.nvim",
	"https://github.com/nvim-mini/mini.splitjoin",
})

-- require("split").setup({
-- 	keymaps = {
-- 		["<leader>m"] = {
-- 			pattern = "[,;]",
-- 			operator_pending = true,
-- 		},
-- 	},
-- })

require("mini.splitjoin").setup()

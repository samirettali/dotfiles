return {
	"folke/trouble.nvim",
	config = function()
		local trouble = require("trouble")

		trouble.setup()

		vim.keymap.set("n", "<leader>te", function()
			trouble.toggle("diagnostics")
		end)

		vim.keymap.set("n", "]e", function()
			trouble.prev({ skip_groups = true, jump = true, mode = "diagnostics" })
		end)

		vim.keymap.set("n", "[e", function()
			trouble.next({ skip_groups = true, jump = true, mode = "diagnostics" })
		end)
	end,
}

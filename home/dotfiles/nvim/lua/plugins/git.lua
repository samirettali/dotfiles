return {
	"sindrets/diffview.nvim", -- Improve diff view
	"rhysd/committia.vim", -- Better commit editing
	{
		-- Git signs integration
		"lewis6991/gitsigns.nvim",
		config = function()
			local gitsigns = require("gitsigns")

			gitsigns.setup()

			vim.keymap.set("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end)

			vim.keymap.set("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end)

			vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk)
			vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk)
			vim.keymap.set("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)
			vim.keymap.set("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)

			vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk)
			vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk)
			vim.keymap.set("n", "<enter>", gitsigns.preview_hunk)
			vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame)
			vim.keymap.set("n", "<leader>hd", gitsigns.diffthis)
			vim.keymap.set("n", "<leader>td", gitsigns.toggle_deleted)

			vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
		end,
	},
	{
		"rhysd/git-messenger.vim",
		config = function()
			vim.g.git_messenger_include_diff = "current"
			vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
		end,
	},
}

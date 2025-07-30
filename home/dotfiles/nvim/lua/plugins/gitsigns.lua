return {
	-- Git signs integration
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPost" },
	config = function()
		local gitsigns = require("gitsigns")

		local opts = {
			current_line_blame = false,
			current_line_blame_opts = {
				-- TODO: maybe set to 10ms if it starts to lag
				delay = 0,
			},
		}

		gitsigns.setup(opts)

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
		vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer)
		-- vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer) -- TODO: this is dangerous

		vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk)
		vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk)
		vim.keymap.set("n", "<leader>hd", gitsigns.diffthis)
		-- vim.keymap.set("n", "<leader>td", gitsigns.toggle_deleted) -- TODO

		vim.keymap.set("n", "<leader>tg", gitsigns.toggle_current_line_blame)
		vim.keymap.set("n", "<leader>gb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "[g]it [b]lame line" })

		vim.keymap.set("n", "<leader>gB", gitsigns.blame, { desc = "[g]it [B]lame file" })

		vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk)

		vim.keymap.set("n", "<leader>qh", function()
			gitsigns.setqflist("all")
		end)
		vim.keymap.set("n", "<leader>qH", gitsigns.setqflist)
	end,
}

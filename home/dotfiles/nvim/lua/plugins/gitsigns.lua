vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = { delay = 0 },
	attach_to_untracked = true,
})

vim.keymap.set("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("gitsigns").nav_hunk("next")
	end
end)

vim.keymap.set("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("gitsigns").nav_hunk("prev")
	end
end)

vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk, { desc = "Git: stage hunk" })
vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { desc = "Git: reset hunk" })
vim.keymap.set("n", "<leader>hR", require("gitsigns").reset_buffer, { desc = "Git: reset buffer" })
vim.keymap.set("n", "<leader>hu", require("gitsigns").undo_stage_hunk, { desc = "Git: undo stage hunk" })
vim.keymap.set("n", "<leader>hp", require("gitsigns").preview_hunk, { desc = "Git: preview hunk" })
vim.keymap.set("n", "<leader>hi", require("gitsigns").preview_hunk_inline, { desc = "Git: preview hunk inline" })
vim.keymap.set("n", "<leader>hB", require("gitsigns").blame, { desc = "Git: blame file" })
vim.keymap.set({ "o", "x" }, "ih", require("gitsigns").select_hunk, { desc = "inside a hunk" })

vim.keymap.set("v", "<leader>hs", function()
	require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Git: stage hunk (visual)" })

vim.keymap.set("v", "<leader>hr", function()
	require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Git: reset hunk (visual)" })

vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Git: blame line" })

vim.keymap.set("n", "<leader>hq", function()
	require("gitsigns").setqflist("all")
end, { desc = "Git: send hunks to quickfix list" })


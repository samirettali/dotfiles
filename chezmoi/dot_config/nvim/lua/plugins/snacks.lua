vim.pack.add({ "https://github.com/folke/snacks.nvim" })
-- vim.cmd("packadd snacks.nvim")

require("snacks").setup({
	picker = { enabled = true },
	notifier = { enabled = false },
	bigfile = { enabled = true },
	input = { enabled = true },
	styles = {
		input = {
			relative = "cursor",
		},
	},
	lazygit = { enabled = true },
	-- dashboard = { enabled = true },
})

vim.keymap.set("n", "<c-f>", function()
	Snacks.picker.files({
		layout = {
			preview = false,
			layout = {
				max_width = 100,
				max_height = 20,
			},
		},
	})
end, { desc = "Snacks: files" })

vim.keymap.set("n", "<c-g>", function()
	Snacks.picker.grep({
		layout = {
			preview = false,
		},
	})
end, { desc = "Snacks: grep files" })

vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Snacks: git diff" })

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Snacks: diagnostics" })

vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Snacks: buffers" })

vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Snacks: help" })

vim.keymap.set("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, { desc = "Snacks: keymaps" })

vim.keymap.set("n", "gri", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Snacks: LSP implementations" })

vim.keymap.set("n", "grr", function()
	Snacks.picker.lsp_references()
end, { desc = "Snacks: LSP references" })

vim.keymap.set("n", "<leader>fq", function()
	Snacks.picker.qflist()
end, { desc = "Snacks: quickfix list" })

vim.keymap.set("n", "gO", function()
	Snacks.picker.lsp_symbols({
		layout = {
			preview = false,
		},
	})
end, { desc = "Snacks: LSP Symbols" })

vim.keymap.set("n", "<leader>fw", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Snacks: LSP workspace symbols" })

vim.keymap.set("n", "<leader>fn", function()
	Snacks.picker.notifications()
end, { desc = "Snacks: notification history" })

vim.keymap.set("n", "<leader>ft", function()
	Snacks.picker.colorschemes()
end, { desc = "Snacks: colorschemes" })

vim.keymap.set("n", "<leader>fm", function()
	Snacks.picker.marks()
end, { desc = "Snacks: marks" })

vim.keymap.set("n", "<localleader>e", function()
	Snacks.picker.explorer({
		layout = {
			layout = {
				position = "right",
			},
		},
	})
end, { desc = "Snacks: explorer" })

-- vim.keymap.set("n", "<leader>ss", function()
-- 	Snacks.picker.actions.load_session()
-- end, { desc = "Snacks load session" })

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ev)
		local value = ev.data.params.value
		vim.api.nvim_echo({ { value.message or "done" } }, false, {
			id = "lsp." .. ev.data.params.token,
			kind = "progress",
			source = "vim.lsp",
			title = value.title,
			status = value.kind ~= "end" and "running" or "success",
			percent = value.percentage,
		})
	end,
})

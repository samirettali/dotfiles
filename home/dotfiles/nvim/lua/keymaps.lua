-- Herdr forwards ctrl+hjkl to us instead of moving pane focus, because nvim is
-- in its keys.passthrough_commands. Move between windows here, and hand the key
-- back to Herdr only when there is no window left in that direction.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	vim.keymap.set("n", "<C-" .. key .. ">", function()
		local from = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(key)
		if vim.api.nvim_get_current_win() == from and vim.env.HERDR_PANE_ID then
			vim.system({ "herdr", "pane", "focus", "--direction", direction })
		end
	end, { desc = "Focus window or pane " .. direction })
end

vim.keymap.set("i", "<C-n>", function()
	return vim.fn.pumvisible() == 1 and "<Down>" or "<C-n>"
end, { expr = true, desc = "Select next completion without inserting" })

vim.keymap.set("i", "<C-p>", function()
	return vim.fn.pumvisible() == 1 and "<Up>" or "<C-p>"
end, { expr = true, desc = "Select previous completion without inserting" })

vim.keymap.set("n", "<leader>g", "<cmd>Grep <cword><cr>", { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

-- nnoremap <silent><esc><esc> :nohlsearch<CR>
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<leader>ta", function()
	vim.lsp.enable("copilot", not vim.lsp.is_enabled("copilot"))
end, { desc = "Toggle copilot lsp" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.keymap.set("n", "<leader>tf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
end, { desc = "Toggle format on save" })

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>tv", function()
	vim.diagnostic.config({
		virtual_lines = not vim.diagnostic.config().virtual_lines,
	})
end, { desc = "Toggle diagnostic virtual lines" })

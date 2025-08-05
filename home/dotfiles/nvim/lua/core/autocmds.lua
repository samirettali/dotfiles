vim.api.nvim_create_autocmd("VimResized", {
	desc = "Automatically resize windows when terminal is resized",
	pattern = "*",
	-- command = "tabdo wincmd =", -- TODO: this leaves you in the last tab
	command = "wincmd =",
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	desc = "Return cursor to where it was last time closing the file",
	group = vim.api.nvim_create_augroup("CustomCursorPosition", { clear = true }),
	pattern = "*",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	desc = "Create parent folder if it doesnt exist when saving a file",
	pattern = "*",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if dir:match("^%a+://") == nil then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- TODO: workaround until https://github.com/folke/lazy.nvim/issues/1951 is fixed
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: fix backdrop for lazy window",
	pattern = "lazy_backdrop",
	group = vim.api.nvim_create_augroup("lazynvim-fix", { clear = true }),
	callback = function(ctx)
		local win = vim.fn.win_findbuf(ctx.buf)[1]
		vim.api.nvim_win_set_config(win, { border = "none" })
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("HighlightYankedText", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Close some filetypes with q",
	pattern = {
		-- TODO: remove non used ones
		"qf",
		"man",
		"help",
		"PlenaryTestPopup",
		"lspinfo",
		"notify",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	group = vim.api.nvim_create_augroup("QuitInQuickfixLoclistHelp", { clear = true }),
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Setup zellij keymaps",
	pattern = "*",
	callback = function()
		local zellij = require("core.zellij")

		vim.keymap.set("n", "<C-h>", zellij.left, { silent = true, desc = "Navigate left in Zellij" })
		vim.keymap.set("n", "<C-j>", zellij.down, { silent = true, desc = "Navigate down in Zellij" })
		vim.keymap.set("n", "<C-k>", zellij.up, { silent = true, desc = "Navigate up in Zellij" })
		vim.keymap.set("n", "<C-l>", zellij.right, { silent = true, desc = "Navigate right in Zellij" })
	end,
})

vim.api.nvim_create_autocmd("CompleteChanged", {
	group = vim.api.nvim_create_augroup("hax", {}),
	desc = "Set NormalFloatPreview highlight and preview window width",
	callback = function()
		vim.schedule(function()
			local rv = vim.fn.complete_info()

			local winid = rv.preview_winid
			if winid then
				vim.wo[winid].winhighlight = "Normal:NormalFloatPreview"
				-- TODO
				-- vim.api.nvim_win_set_config(winid, {
				-- 	winwidth = 30,
				-- 	-- border = "rounded",
				-- })
			end

			local bufnr = rv.preview_bufnr
			if bufnr then
				vim.bo[bufnr].filetype = "markdown"
			end
		end)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Disable new line comments",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

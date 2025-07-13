vim.api.nvim_create_autocmd("VimResized", {
	pattern = "*",
	desc = "Automatically resize windows when terminal is resized",
	command = "wincmd =",
})

-- vim.api.nvim_create_autocmd("FileType", {
--     desc = "Close help, man, quickfix, lspinfo with q",
--     pattern = { "qf", "help", "man", "lspinfo" },
--     callback = function()
--         vim.keymap.set("n", "q", ":close<CR>")
--     end,
-- })

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

-- Create parent folder if it doesnt exist when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	pattern = "*",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if dir:match("^%a+://") == nil then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

local set_cursorline = function(event, value, pattern)
	vim.api.nvim_create_autocmd(event, {
		desc = "Keep cursor line only on focused window",
		group = vim.api.nvim_create_augroup("CustomCursorLineControl", { clear = true }),
		pattern = pattern,
		callback = function()
			vim.opt_local.cursorline = value
		end,
	})
end
set_cursorline("WinEnter", true)
set_cursorline("InsertLeave", true)
set_cursorline("InsertEnter", false)
set_cursorline("WinLeave", false)
set_cursorline("FileType", false, "TelescopePrompt")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	desc = "Enable spell checking for certain file types",
	pattern = { "*.txt", "*.md" },
	callback = function()
		vim.opt.spell = true
		vim.opt.spelllang = "en" -- TODO: download italian dictionary
	end,
})

vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		data = {
			run = function(_)
				vim.cmd("TSUpdate")
			end,
		},
	},
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/felipeagc/fleet-theme-nvim" },
	{ src = "https://github.com/stevearc/quicker.nvim" },
})

vim.cmd("packadd nvim.undotree") -- built in
vim.cmd("packadd nvim-treesitter")
vim.cmd("packadd nvim-treesitter-textobjects")
vim.cmd("packadd oil.nvim")
vim.cmd("packadd gitsigns.nvim")
vim.cmd("packadd fleet-theme-nvim")
vim.cmd("packadd quicker.nvim")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 1
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevelstart = 99
-- vim.opt.diffopt = "internal,filler,closeoff,algorithm:histogram,context:5,linematch:60" -- TODO: read docs
-- vim.opt.statusline = '[%n] %<%f %h%w%m%r%=%-14.(%l,%c%V%) %P' -- https://github.com/y9san9/y9san9.nvim/blob/main/init.lua
vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
	"noinsert",
	"fuzzy",
	"popup",
}
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.shortmess:append("c")
vim.opt.shortmess:append("I")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.cmd.colorscheme("fleet")

-- diagnostic and lsp
vim.diagnostic.config({ signs = false })

vim.lsp.enable({
	"bashls",
	"clangd",
	"gopls",
	"golangci_lint_ls",
	"lua_ls",
	"stylua",
	"jsonls",
	"ts_ls", -- TODO: try vtsls
	"eslint",
	"nixd",
	"roslyn_ls",
	"rust_analyzer",
	"solidity_ls",
	"yamlls",
	"buf_ls",
	"copilot",
	"basedpyright",
	"ruff",
})

local on_lsp_attach = function(ev)
	-- TODO: should the buffer checked to be modifiable etc?
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if client == nil then
		vim.notify("LSP client not found for id " .. ev.data.client_id, vim.log.levels.WARN)
		return
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
		vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
		local win = vim.api.nvim_get_current_win()
		vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_onTypeFormatting) then
		vim.lsp.on_type_formatting.enable(true, { client_id = ev.data.client_id })
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_definition) then
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "vim.lsp.buf.definition()" })
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
		vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })

		vim.keymap.set(
			"i",
			"<tab>",
			vim.lsp.inline_completion.get,
			{ desc = "LSP: accept inline completion", buffer = ev.buf }
		)

		vim.keymap.set(
			"i",
			"<c-g>",
			vim.lsp.inline_completion.select,
			{ desc = "LSP: switch inline completion", buffer = ev.buf }
		)
	end
end

local function on_lsp_detach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if client == nil then
		return
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
		local win = vim.api.nvim_get_current_win()
		vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end
end

-- plugins setup
require("oil").setup({
	default_file_explorer = false,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = false,
	},
})

require("quicker").setup()
require("nvim-treesitter").install("all")
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
	move = {
		set_jumps = true,
	},
})

require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = { delay = 0 },
	attach_to_untracked = true,
})

local select = require("nvim-treesitter-textobjects.select")
local swap = require("nvim-treesitter-textobjects.swap")
local move = require("nvim-treesitter-textobjects.move")

-- autocmds
vim.api.nvim_create_autocmd("LspAttach", { callback = on_lsp_attach })
vim.api.nvim_create_autocmd("LspDetach", { callback = on_lsp_detach })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("HighlightYankedText", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Disable new line comments",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("AutoFormat", { clear = true }),
	callback = function(args)
		if
			vim.g.disable_autoformat
			or vim.bo[args.buf].buftype ~= ""
			or not vim.bo[args.buf].modifiable
			or vim.api.nvim_buf_get_name(args.buf) == ""
		then
			return
		end

		vim.lsp.buf.format({
			bufnr = args.buf,
			filter = function(c)
				return c.name ~= "lua_ls" and c:supports_method(vim.lsp.protocol.Methods.textDocument_formatting)
			end,
		})
	end,
})
-- custom commands
vim.api.nvim_create_user_command("PackClean", function()
	local plugins = vim.pack.get()
	local to_delete = {}
	for _, plugin in ipairs(plugins) do
		if not plugin.active then
			table.insert(to_delete, plugin.spec.name)
		end
	end

	vim.pack.del(to_delete)
end, { desc = "Remove unused plugins" })

vim.api.nvim_create_user_command("PackList", function()
	vim.pack.update(nil, { offline = true })
end, { desc = "List plugins" })

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update plugins" })

vim.api.nvim_create_user_command("Grep", function(opts)
	-- TODO: args or fargs?
	local query = table.concat(opts.fargs, " ")
	vim.cmd("silent! grep! " .. query)
	vim.cmd("cwindow")
	vim.cmd("redraw!")
end, { nargs = "+", desc = "Run grep with the given query" })

-- keymaps
vim.keymap.set("n", "<leader>g", "<cmd>Grep <cword><cr>", { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

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

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<cmd>Oil .<cr>", { desc = "Open root directory" })

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

-- Selection objects
vim.keymap.set({ "x", "o" }, "aa", function()
	select.select_textobject("@parameter.outer", "textobjects")
end, { desc = "around a parameter" })
vim.keymap.set({ "x", "o" }, "ia", function()
	select.select_textobject("@parameter.inner", "textobjects")
end, { desc = "inside a parameter" })

vim.keymap.set({ "x", "o" }, "af", function()
	select.select_textobject("@function.outer", "textobjects")
end, { desc = "around a function" })
vim.keymap.set({ "x", "o" }, "if", function()
	select.select_textobject("@function.inner", "textobjects")
end, { desc = "inside a function" })

vim.keymap.set({ "x", "o" }, "ac", function()
	select.select_textobject("@class.outer", "textobjects")
end, { desc = "around a class" })
vim.keymap.set({ "x", "o" }, "ic", function()
	select.select_textobject("@class.inner", "textobjects")
end, { desc = "inside a class" })

vim.keymap.set({ "x", "o" }, "al", function()
	select.select_textobject("@loop.outer", "textobjects")
end, { desc = "around a loop" })
vim.keymap.set({ "x", "o" }, "il", function()
	select.select_textobject("@loop.inner", "textobjects")
end, { desc = "inside a loop" })

vim.keymap.set({ "x", "o" }, "ai", function()
	select.select_textobject("@conditional.outer", "textobjects")
end, { desc = "around an if statement" })
vim.keymap.set({ "x", "o" }, "ii", function()
	select.select_textobject("@conditional.inner", "textobjects")
end, { desc = "inside an if statement" })

vim.keymap.set({ "x", "o" }, "a=", function()
	select.select_textobject("@assignment.outer", "textobjects")
end, { desc = "around an assignment" })
vim.keymap.set({ "x", "o" }, "i=", function()
	select.select_textobject("@assignment.inner", "textobjects")
end, { desc = "inside an assignment" })

vim.keymap.set({ "x", "o" }, "l=", function()
	select.select_textobject("@assignment.lhs", "textobjects")
end, { desc = "left-hand side of an assignment" })
vim.keymap.set({ "x", "o" }, "r=", function()
	select.select_textobject("@assignment.rhs", "textobjects")
end, { desc = "right-hand side of an assignment" })

-- Movement between objects
vim.keymap.set("n", "[f", function()
	move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function" })
vim.keymap.set("n", "]f", function()
	move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function" })

vim.keymap.set("n", "[F", function()
	move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set("n", "]F", function()
	move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })

-- TODO: this conflicts with diff jump
-- vim.keymap.set("n", "[c", function()
-- 	move.goto_previous_start("@class.outer", "textobjects")
-- end, { desc = "Previous class" })
-- vim.keymap.set("n", "]c", function()
-- 	move.goto_next_start("@class.outer", "textobjects")
-- end, { desc = "Next class" })

vim.keymap.set("n", "[C", function()
	move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })
vim.keymap.set("n", "]C", function()
	move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })

vim.keymap.set("n", "[p", function()
	move.goto_previous_start("@parameter.inner", "textobjects")
end, { desc = "Previous parameter" })
vim.keymap.set("n", "]p", function()
	move.goto_next_start("@parameter.inner", "textobjects")
end, { desc = "Next parameter" })

-- Swap objects
vim.keymap.set("n", "g>", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap parameter with next" })
vim.keymap.set("n", "g<", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap parameter with previous" })

-- functions
P = function(x)
	print(vim.inspect(x))
	return x
end

N = function(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

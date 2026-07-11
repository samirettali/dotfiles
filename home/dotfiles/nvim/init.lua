-- functions
function P(x)
	print(vim.inspect(x))
	return x
end

function N(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

require("plugins.nvim-treesitter")
require("plugins.nvim-treesitter-textobjects")
require("plugins.oil")
vim.pack.add({
})
require("plugins.gitsigns")
require("plugins.moonfly")
vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

vim.cmd("packadd nvim.undotree") -- built in

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.autoread = true
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
vim.opt.fillchars = { eob = " " }
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"

require("ui.tabline")
require("autocmds")
require("plugins.nightfly")
require("plugins.auto-dark-mode")

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
	"harper",
	"dartls",
})

local on_lsp_attach = function(ev)
	-- TODO: should the buffer checked to be modifiable etc?
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if client == nil then
		vim.notify("LSP client not found for id " .. ev.data.client_id, vim.log.levels.WARN)
		return
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
		local kind_hl = {
			Text = "String",
			Method = "Function",
			Function = "Function",
			Constructor = "Function",
			Field = "@lsp.type.property",
			Variable = "@variable",
			Class = "Include",
			Interface = "Type",
			Module = "Exception",
			Property = "@lsp.type.property",
			Unit = "Number",
			Value = "@variable",
			Enum = "Number",
			Keyword = "Keyword",
			Snippet = "Keyword",
			Color = "Keyword",
			File = "Tag",
			Reference = "Function",
			Folder = "Function",
			EnumMember = "Number",
			Constant = "Constant",
			Struct = "Type",
			Event = "Constant",
			Operator = "Operator",
			TypeParameter = "Type",
		}

		vim.lsp.completion.enable(true, client.id, ev.buf, {
			autotrigger = true,
			convert = function(item)
				local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "Text"
				if item.data and item.data.bufnames then
					kind = "Buffer"
				end

				local hl = kind_hl[kind] or "Normal"

				return {
					abbr = item.label,
					kind = kind,
					menu = "",
					kind_hlgroup = hl,
				}
			end,
		})
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
require("plugins")

-- autocmds
vim.api.nvim_create_autocmd("VimResized", {
	desc = "Automatically resize windows when terminal is resized",
	pattern = "*",
	-- command = "tabdo wincmd =", -- TODO: this leaves you in the last tab
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("LspAttach", { callback = on_lsp_attach })
vim.api.nvim_create_autocmd("LspDetach", { callback = on_lsp_detach })
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

		local clients = vim.lsp.get_clients({ bufnr = args.buf })

		local ok = false

		for _, client in ipairs(clients) do
			if client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
				ok = true
				break
			end
		end

		if not ok then
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

----------------- yooooooooooo
-- vim.opt.wildmode = "noselect"
-- vim.api.nvim_create_autocmd("CmdlineChanged", {
-- 	pattern = ":",
-- 	callback = function()
-- 		vim.fn.wildtrigger()
-- 	end,
-- })

-- function _G.my_find(text, _)
-- 	local files = vim.fn.glob("**/*", true, true)
-- 	-- return { "%#DiagnosticError#" .. text .. "%*" .. "\t" .. "%#DiagnosticHint#" .. "in " .. files }
-- 	local result = vim.fn.matchfuzzy(files, text)
-- 	P(result)
-- 	return result
-- end
--
-- vim.opt.findfunc = "v:lua.my_find"

-------------------------------------

vim.api.nvim_create_user_command("Bufferize", function(opts)
	-- TODO: maybe make a version that takes a lua expression, evaluates it and prints it using vim.inspect
	local cmd = opts.args

	if cmd == "" then
		vim.notify("Please provide a Vim command to run", vim.log.levels.ERROR)
		return
	end

	local output = vim.fn.execute(cmd)

	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	local bufname = ("[Vim Command Output]: %s"):format(cmd)
	vim.api.nvim_buf_set_name(buf, bufname)

	local lines = vim.split(output, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
end, {
	nargs = "+",
	complete = "command",
	desc = "Run a Vim command and show output in a new buffer",
})

vim.cmd(":command! E e")
vim.cmd(":command! W w")
vim.cmd(":command! Q q")
vim.cmd(":command! Wq wq")
vim.cmd(":command! WQ wq")
vim.cmd(":command! Qa qa")
vim.cmd(":command! QA qa")
vim.cmd(":command! Wa wa")
vim.cmd(":command! WA wa")
vim.cmd(":command! Wqa wqa")
vim.cmd(":command! WQa wqa")
vim.cmd(":command! WQA wqa")
vim.cmd(":command! Cq cq")
vim.cmd(":command! CQ cq")

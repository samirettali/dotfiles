P = function(x)
	print(vim.inspect(x))
	return x
end

N = function(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
-- vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"
vim.opt.clipboard = "unnamedplus"
vim.opt.diffopt = "internal,filler,closeoff,algorithm:histogram,context:5,linematch:60" -- TODO: read docs
-- TODO: is this needed?
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4
vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
	"noinsert",
	"fuzzy",
}
-- vim.opt.shortmess:append("c")
-- vim.opt.shortmess:append("I")
-- TODO: is this needed?
-- if os.getenv("SSH_TTY") and os.getenv("SSH_CLIENT") then
-- 	local clipboard = require("vim.ui.clipboard.osc52")
--
-- 	vim.g.clipboard = {
-- 		name = "OSC 52",
-- 		copy = {
-- 			["+"] = clipboard.copy("+"),
-- 			["*"] = clipboard.copy("*"),
-- 		},
-- 		paste = {
-- 			["+"] = clipboard.paste("+"),
-- 			["*"] = clipboard.paste("*"),
-- 		},
-- 	}
-- end
-- vim.opt.listchars = {
-- 	tab = "»·",
-- 	trail = "·",
-- 	nbsp = "~",
-- 	eol = "¬",
-- }
vim.opt.fillchars = {
	-- 	diff = "╱",
	-- 	horiz = "━",
	-- 	horizup = "┻",
	-- 	horizdown = "┳",
	-- 	vert = "┃",
	-- 	vertleft = "┫",
	-- 	vertright = "┣",
	-- 	verthoriz = "╋",
	eob = " ",
	-- 	fold = "─",
	-- 	foldopen = "▾",
	-- 	foldsep = " ",
	-- 	foldclose = "▸",
}
-- vim.opt.showbreak = "↳ "
-- vim.opt.statusline = " "
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- statuscolumn
_G.StatuscolSign = function()
	local marks = vim.api.nvim_buf_get_extmarks(
		0,
		-1,
		{ vim.v.lnum - 1, 0 },
		{ vim.v.lnum - 1, -1 },
		{ details = true }
	)
	for _, mark in ipairs(marks) do
		local details = mark[4]
		if details and details.sign_text then
			local hl = details.sign_hl_group or "SignColumn"
			return "%#" .. hl .. "#" .. details.sign_text .. "%*"
		end
	end
	return "   "
end

vim.opt.statuscolumn = "%{%v:lua.StatuscolSign()%}%=%4{v:relnum == 0 ? v:lnum : v:relnum}  "

vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		data = {
			run = function(_)
				vim.cmd("TSUpdate")
			end,
		},
	},
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	"https://github.com/bluz71/vim-moonfly-colors",
	"https://github.com/echasnovski/mini.ai",
	"https://github.com/echasnovski/mini.diff",
	"https://github.com/echasnovski/mini.extra",
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/echasnovski/mini.pick",
	"https://github.com/echasnovski/mini.sessions",
	"https://github.com/echasnovski/mini.splitjoin",
	"https://github.com/echasnovski/mini.surround",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	"https://github.com/rlane/pounce.nvim",
	"https://github.com/danymat/neogen",
	"https://github.com/nat-418/boole.nvim",
	"https://github.com/stevearc/quicker.nvim",
	"https://github.com/kevinhwang91/nvim-bqf",
})

vim.cmd("packadd nvim.undotree") -- built in
vim.cmd("packadd vim-moonfly-colors")
vim.cmd("packadd nvim-treesitter")
vim.cmd("packadd nvim-treesitter-textobjects")
-- vim.cmd("packadd "mini.ai")
vim.cmd("packadd mini.diff")
vim.cmd("packadd mini.extra")
vim.cmd("packadd mini.icons")
vim.cmd("packadd mini.pick")
vim.cmd("packadd mini.sessions")
vim.cmd("packadd mini.splitjoin")
vim.cmd("packadd mini.surround")
vim.cmd("packadd conform.nvim")
vim.cmd("packadd nvim-lint")
vim.cmd("packadd pounce.nvim")
vim.cmd("packadd quicker.nvim")
vim.cmd("packadd nvim-bqf")
vim.cmd("packadd oil.nvim")
vim.cmd("packadd boole.nvim")
vim.cmd("packadd neogen")

-- diagnostic and lsp
local function on_jump(_, bufnr)
	vim.diagnostic.open_float({
		bufnr = bufnr,
		scope = "cursor",
		focus = false,
		source = true,
	})
end

vim.diagnostic.config({
	float = {
		header = "",
		scope = "cursor",
		source = true,
	},
	virtual_lines = false,
	virtual_text = false,
	underline = true,
	severity_sort = true,
	signs = false,
	jump = { on_jump = on_jump },
})

vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("gopls")
vim.lsp.enable("jsonls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("roslyn_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("ts_ls") -- TODO: try vtsls
vim.lsp.enable("solidity_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("buf_ls")
vim.lsp.enable("copilot")
vim.lsp.enable("basedpyright")
-- vim.lsp.enable("ruff")
-- vim.lsp.enable("pyrefly")
-- vim.lsp.enable("ty")
-- vim.lsp.enable("zls")
-- vim.lsp.enable("ocamllsp")
-- vim.lsp.enable("terraformls") -- TODO: activate only if terraform-ls is installed
-- vim.lsp.enable("jdtls")
-- vim.lsp.enable("taplo")

local on_attach = function(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if client == nil then
		return
	end

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

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
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

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
		local opts = {
			bufnr = ev.buf,
		}

		vim.lsp.inline_completion.enable(true, opts)
		vim.keymap.set(
			"i",
			"<Tab>",
			vim.lsp.inline_completion.get,
			{ desc = "LSP: accept inline completion", buffer = ev.buf }
		)

		vim.keymap.set(
			"i",
			"<C-g>",
			vim.lsp.inline_completion.select,
			{ desc = "LSP: switch inline completion", buffer = ev.buf }
		)
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_onTypeFormatting) then
		vim.lsp.on_type_formatting.enable(true, { client_id = ev.data.client_id })
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_definition) then
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "vim.lsp.buf.definition()" })
	end
end

local function on_detach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if client == nil then
		return
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
		local win = vim.api.nvim_get_current_win()
		vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end
end

-- Plugins setup
local moonfly = require("moonfly")

moonfly.custom_colors({ bg = "#000000" })

local palette = moonfly.palette

vim.g.moonflyWinSeparator = 2
vim.g.moonflyVirtualTextColor = true
vim.g.moonflyNormalFloat = true
vim.g.moonflyNormalPmenu = true
vim.g.moonflyUnderlineMatchParen = true
vim.g.moonflyItalics = false
vim.g.moonflyUndercurls = true

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MoonflyColors", { clear = true }),
	pattern = "moonfly",
	callback = function()
		-- vim.api.nvim_set_hl(0, "WinBar", { bg = palette.bg, fg = palette.grey39 })
		-- vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.bg, fg = palette.grey39 })
		-- vim.api.nvim_set_hl(0, "BqfSign", { bg = palette.bg, fg = palette.emerald })
		-- vim.api.nvim_set_hl(0, "TablineSel", { bg = palette.bg, fg = palette.white })
		-- vim.api.nvim_set_hl(0, "Tabline", { bg = palette.bg, fg = palette.grey39 })
		-- vim.api.nvim_set_hl(0, "TablineFill", { bg = palette.bg })
		-- vim.api.nvim_set_hl(0, "TreesitterContext", { bg = palette.bg })
		-- vim.api.nvim_set_hl(0, "StatusLine", { bg = palette.bg })
		-- vim.api.nvim_set_hl(0, "NormalFloatPreview", { bg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceMatch", { bg = palette.lime, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceUnmatched", { link = "Comment" })
		-- vim.api.nvim_set_hl(0, "PounceGap", { bg = palette.emerald, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceAccept", { bg = palette.orange, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceAcceptBest", { bg = palette.red, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceCursor", { bg = palette.red, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceCursorGap", { bg = palette.cranberry, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceCursorAccept", { bg = palette.orange, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "PounceCursorAcceptBest", { bg = palette.red, fg = palette.grey11 })
		-- vim.api.nvim_set_hl(0, "CursorLine", { bg = palette.black })
		-- vim.api.nvim_set_hl(0, "CursorLineNr", { bg = palette.black })
	end,
})

vim.cmd.colorscheme("moonfly")

-- boole.nvim
require("boole").setup({
	mappings = {
		increment = "<C-a>",
		decrement = "<C-x>",
	},
})

-- bqf
vim.fn.sign_define("BqfSign", { text = " ", texthl = "BqfSign" }) -- TODO: this is missing in moonfly
require("bqf").setup({
	preview = {
		auto_preview = false,
		win_height = 25,
		show_scroll_bar = false,
	},
})

-- quicker.nvim
require("quicker").setup()

-- oil.nvim
require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = false,
	},
})

-- neogen
local neogen = require("neogen")
neogen.setup()

-- pounce
require("pounce").setup({
	increase_cmd_height_if_zero = true,
})

-- mini.sessions
require("mini.sessions").setup({
	autoread = true,
	autowrite = true,
})

-- mini.icons
require("mini.icons").setup({ style = "ascii" })
MiniIcons.mock_nvim_web_devicons()

-- mini.pick
require("mini.pick").setup({
	mappings = {
		select_all_to_qf = {
			char = "<C-q>",
			func = function()
				local matches = require("mini.pick").get_picker_matches()
				if not matches or not matches.all or #matches.all == 0 then
					return false
				end

				require("mini.pick").default_choose_marked(matches.all)

				-- stop the picker after sending to the quickfix list
				return true
			end,
		},
	},
})

-- mini.diff
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "┃", change = "┃", delete = "┃" },
	},
	delay = {
		text_change = 0,
	},
})

-- mini.splitjoin
require("mini.splitjoin").setup({
	mappings = {
		toggle = "<leader>m",
	},
})

-- mini.extra
require("mini.extra").setup()

-- mini.surround
require("mini.surround").setup()

-- -- mini.ai
-- local gen_ai_spec = require("mini.extra").gen_ai_spec
-- require("mini.ai").setup({
-- 	custom_textobjects = {
-- 		e = gen_ai_spec.buffer(),
-- 		D = gen_ai_spec.diagnostic(),
-- 		I = gen_ai_spec.indent(),
-- 		L = gen_ai_spec.line(),
-- 		N = gen_ai_spec.number(),
-- 	},
-- })

-- lint.nvim
local lint = require("lint")
lint.linters_by_ft = {
	go = { "revive", "golangcilint" },
	javascript = { "eslint_d" },
	cpp = { "clang-tidy", "cppcheck", "cpplint" },
	bash = { "shellcheck" },
}

local lint_augroup = vim.api.nvim_create_augroup("linting", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	group = lint_augroup,
	callback = function()
		lint.try_lint()
	end,
})

-- treesitter
local treesitter = require("nvim-treesitter")
local config = require("nvim-treesitter.config")

local ensure_installed = {
	"c",
	"cpp",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"python",
	"rust",
	"typescript",
	"yaml",
	"nix",
}

treesitter.install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(args.match)
		if lang and vim.list_contains(config.get_installed(), lang) then
			vim.treesitter.start(args.buf)
		end
	end,
})

-- treesitter textobjects-
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
	move = {
		set_jumps = true,
	},
	lsp_interop = { -- TODO: old
		enable = true,
		border = "none",
		floating_preview_opts = {},
	},
})

-- conform.nvim
require("conform").setup({
	format_after_save = function()
		if vim.g.disable_autoformat then
			return
		end
		return { timeout_ms = 3000, lsp_format = "fallback" }
	end,

	-- TODO: try sqlfluff and sqlfmt
	formatters_by_ft = {
		cpp = { "clang-format" },
		cs = { "csharpier" },
		css = { "css_beautify" },
		go = { "goimports", "gofumpt" },
		javascript = { "prettierd" },
		lua = { "stylua" },
		nix = { "alejandra" },
		python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		toml = { "taplo" },
		typescript = { "prettierd" },
		wgsl = { "wgslfmt" },
		yaml = { "yamlfmt" },
		fish = { "fish_indent" },
		json = { "jq" },
		proto = { "buf" },
		-- ["*"] = { "codespell" },
		["_"] = { "trim_whitespace" },
	},
})

-- keymaps
vim.keymap.set("n", "<C-f>", "<CMD>Pick files<CR>", { desc = "Pick files" })
vim.keymap.set("n", "<C-g>", "<CMD>Pick grep_live<CR>", { desc = "Pick grep live" })
vim.keymap.set("n", "<leader>fb", "<CMD>Pick buffers<CR>", { desc = "Pick buffers" })
vim.keymap.set("n", "<leader>fr", "<CMD>Pick resume<CR>", { desc = "Resume picker" })
vim.keymap.set("n", "<leader>fg", "<CMD>Pick git_hunks<CR>", { desc = "Git hunks" })
vim.keymap.set("n", "<leader>fh", "<CMD>Pick help<CR>", { desc = "Pick help" })

vim.keymap.set("n", "<leader>fc", "<CMD>Pick commands<CR>", { desc = "Pick commands" })
vim.keymap.set("n", "<leader>fd", "<CMD>Pick diagnostic<CR>", { desc = "Pick diagnostics" })
vim.keymap.set("n", "<leader>fk", "<CMD>Pick keymaps<CR>", { desc = "Pick keymaps" })
vim.keymap.set("n", "<leader>fl", "<CMD>Pick buf_lines scope='current'<CR>", { desc = "Pick lines" })
vim.keymap.set("n", "<leader>fm", "<CMD>Pick marks<CR>", { desc = "Pick marks" })
vim.keymap.set("n", "<leader>fo", "<CMD>Pick options<CR>", { desc = "Pick options" })
vim.keymap.set("n", "<leader>fq", "<CMD>Pick list scope='quickfix'<CR>", { desc = "Pick quickfix" })
vim.keymap.set("n", "<leader>fe", "<CMD>Pick explorer<CR>", { desc = "Pick explorer" })
vim.keymap.set(
	"n",
	"<leader>fs",
	"<CMD>lua require('mini.extra').pickers.lsp({ scope = 'document_symbol' })<CR>",
	{ desc = "Pick lsp document symbol" }
)
vim.keymap.set("n", "<leader>fw", function()
	local scope = vim.fn.input("Query: ", "")
	require("mini.extra").pickers.lsp({ scope = "workspace_symbol", symbol_query = scope })
end, { desc = "Pick lsp workspace symbol" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open root directory" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

vim.keymap.set("n", "<leader>ta", function()
	vim.lsp.enable("copilot", not vim.lsp.is_enabled("copilot"))
end, { desc = "Toggle copilot lsp" })

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.keymap.set("n", "<leader>tv", function()
	vim.diagnostic.config({
		virtual_lines = not vim.diagnostic.config().virtual_lines,
	})
end, { desc = "Toggle diagnostic virtual lines" })

vim.keymap.set("n", "<leader>nf", neogen.generate, { desc = "Neogen: Generate annotation" })
vim.keymap.set("n", "<leader>j", "<CMD>Pounce<CR>", { desc = "Pounce" })
vim.keymap.set("n", "<leader>J", "<CMD>PounceRepeat<CR>", { desc = "Pounce repeat" })

vim.keymap.set("n", "<leader>tf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat

	if vim.g.disable_autoformat then
		vim.notify("Format on save disabled")
	else
		vim.notify("Format on save enabled")
	end
end, { desc = "Toggle format on save" })

-- TODO: needed?
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })

vim.keymap.set("n", "<leader>q", function()
	local jumplist, _ = unpack(vim.fn.getjumplist())
	local qf_list = {}
	for _, v in pairs(jumplist) do
		if vim.fn.bufloaded(v.bufnr) == 1 then
			table.insert(qf_list, {
				bufnr = v.bufnr,
				lnum = v.lnum,
				col = v.col,
				text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1],
			})
		end
	end

	vim.fn.setqflist(qf_list, " ")
	vim.cmd("copen")
end, { desc = "Send jumplist to quickfix window" })

local select = require("nvim-treesitter-textobjects.select")
local swap = require("nvim-treesitter-textobjects.swap")
local move = require("nvim-treesitter-textobjects.move")

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

vim.keymap.set({ "x", "o" }, "as", function()
	select.select_textobject("@scope", "textobjects")
end, { desc = "around a scope" })
vim.keymap.set({ "x", "o" }, "is", function()
	select.select_textobject("@scope", "textobjects")
end, { desc = "inside a scope" })

vim.keymap.set({ "x", "o" }, "it", function()
	select.select_textobject("@type", "textobjects")
end, { desc = "inside a type" })

vim.keymap.set({ "x", "o" }, "ar", function()
	select.select_textobject("@return.outer", "textobjects")
end, { desc = "around a return statement" })
vim.keymap.set({ "x", "o" }, "ir", function()
	select.select_textobject("@return.inner", "textobjects")
end, { desc = "inside a return statement" })

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

vim.keymap.set("n", "[c", function()
	move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class" })
vim.keymap.set("n", "]c", function()
	move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class" })

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

vim.keymap.set("n", "[P", function()
	move.goto_previous_end("@parameter.inner", "textobjects")
end, { desc = "Previous parameter end" })
vim.keymap.set("n", "]P", function()
	move.goto_next_end("@parameter.inner", "textobjects")
end, { desc = "Next parameter end" })

-- Swap objects
vim.keymap.set("n", "<leader>sl", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap parameter with next" })
vim.keymap.set("n", "<leader>sh", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap parameter with previous" })

vim.keymap.set("n", "<space>sj", function()
	swap.swap_next("@block.outer")
end, { desc = "Swap block with next" })
vim.keymap.set("n", "<space>sk", function()
	swap.swap_previous("@block.outer")
end, { desc = "Swap block with previous" })

-- local lsp_interop = require("nvim-treesitter-textobjects.lsp_interop")
-- vim.keymap.set("n", "<leader>df", function() lsp_interop.peek_definition_code('@function.outer') end)
-- vim.keymap.set("n", "<leader>dF", function() lsp_interop.peek_definition_code('@class.outer') end)

-- autocmds
vim.api.nvim_create_autocmd("LspAttach", {
	callback = on_attach,
})

vim.api.nvim_create_autocmd("LspDetach", {
	callback = on_detach,
})

-- TODO: not needed?
-- vim.api.nvim_create_autocmd("VimResized", {
-- 	desc = "Automatically resize windows when terminal is resized",
-- 	pattern = "*",
-- 	-- command = "tabdo wincmd =", -- TODO: this leaves you in the last tab
-- 	command = "wincmd =",
-- })

vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	desc = "Create parent folder if it doesnt exist when saving a file",
	pattern = "*",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if dir:match("^%a+://") ~= nil then
			return
		end

		vim.fn.mkdir(dir, "p")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("HighlightYankedText", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 50 })
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Disable new line comments",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

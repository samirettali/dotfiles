local methods = vim.lsp.protocol.Methods

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
-- vim.keymap.set("n", "gS", function()
-- 	vim.lsp.buf.workspace_symbol()
-- end, { desc = "vim.lsp.buf.workspace_symbol()" })
-- vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
-- vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })

---@type ({menu: string, kind: string, kind_hlgroup: string})[]
-- local kind_icon = {
-- 	{ menu = "Text", kind = "󰦨", kind_hlgroup = "String" },
-- 	{ menu = "Method", kind = "", kind_hlgroup = "Function" },
-- 	{ menu = "Function", kind = "󰡱", kind_hlgroup = "Function" },
-- 	{ menu = "Constructor", kind = "", kind_hlgroup = "Function" },
-- 	{ menu = "Field", kind = "", kind_hlgroup = "@lsp.type.property" },
-- 	{ menu = "Variable", kind = "", kind_hlgroup = "@variable" },
-- 	{ menu = "Class", kind = "", kind_hlgroup = "Include" },
-- 	{ menu = "Interface", kind = "", kind_hlgroup = "Type" },
-- 	{ menu = "Module", kind = "", kind_hlgroup = "Exception" },
-- 	{ menu = "Property", kind = "", kind_hlgroup = "@lsp.type.property" },
-- 	{ menu = "Unit", kind = "󰊱", kind_hlgroup = "Number" },
-- 	{ menu = "Value", kind = "", kind_hlgroup = "@variable" },
-- 	{ menu = "Enum", kind = "", kind_hlgroup = "Number" },
-- 	{ menu = "Keyword", kind = "", kind_hlgroup = "Keyword" },
-- 	{ menu = "Snippet", kind = "", kind_hlgroup = "Keyword" },
-- 	{ menu = "Color", kind = "", kind_hlgroup = "Keyword" },
-- 	{ menu = "File", kind = "", kind_hlgroup = "Tag" },
-- 	{ menu = "Reference", kind = "", kind_hlgroup = "Function" },
-- 	{ menu = "Folder", kind = "󰣞", kind_hlgroup = "Function" },
-- 	{ menu = "EnumMember", kind = "", kind_hlgroup = "Number" },
-- 	{ menu = "Constant", kind = "", kind_hlgroup = "Constant" },
-- 	{ menu = "Struct", kind = "", kind_hlgroup = "Type" },
-- 	{ menu = "Event", kind = "", kind_hlgroup = "Constant" },
-- 	{ menu = "Operator", kind = "", kind_hlgroup = "Operator" },
-- 	{ menu = "TypeParameter", kind = "", kind_hlgroup = "Type" },
-- }

local MiniIcons = require("mini.icons")

local kind_icon = {
	{
		menu = "Text",
		kind = MiniIcons.get("lsp", "text"),
		kind_hlgroup = "String",
	},
	{
		menu = "Method",
		kind = MiniIcons.get("lsp", "method"),
		kind_hlgroup = "Function",
	},
	{
		menu = "Function",
		kind = MiniIcons.get("lsp", "function"),
		kind_hlgroup = "Function",
	},
	{
		menu = "Constructor",
		kind = MiniIcons.get("lsp", "constructor"),
		kind_hlgroup = "Function",
	},
	{
		menu = "Field",
		kind = MiniIcons.get("lsp", "field"),
		kind_hlgroup = "@lsp.type.property",
	},
	{
		menu = "Variable",
		kind = MiniIcons.get("lsp", "variable"),
		kind_hlgroup = "@variable",
	},
	{
		menu = "Class",
		kind = MiniIcons.get("lsp", "class"),
		kind_hlgroup = "Include",
	},
	{
		menu = "Interface",
		kind = MiniIcons.get("lsp", "interface"),
		kind_hlgroup = "Type",
	},
	{
		menu = "Module",
		kind = MiniIcons.get("lsp", "module"),
		kind_hlgroup = "Exception",
	},
	{
		menu = "Property",
		kind = MiniIcons.get("lsp", "property"),
		kind_hlgroup = "@lsp.type.property",
	},
	{
		menu = "Unit",
		kind = MiniIcons.get("lsp", "unit"),
		kind_hlgroup = "Number",
	},
	{
		menu = "Value",
		kind = MiniIcons.get("lsp", "value"),
		kind_hlgroup = "@variable",
	},
	{
		menu = "Enum",
		kind = MiniIcons.get("lsp", "enum"),
		kind_hlgroup = "Number",
	},
	{
		menu = "Keyword",
		kind = MiniIcons.get("lsp", "keyword"),
		kind_hlgroup = "Keyword",
	},
	{
		menu = "Snippet",
		kind = MiniIcons.get("lsp", "snippet"),
		kind_hlgroup = "Keyword",
	},
	{
		menu = "Color",
		kind = MiniIcons.get("lsp", "color"),
		kind_hlgroup = "Keyword",
	},
	{
		menu = "File",
		kind = MiniIcons.get("lsp", "file"),
		kind_hlgroup = "Tag",
	},
	{
		menu = "Reference",
		kind = MiniIcons.get("lsp", "reference"),
		kind_hlgroup = "Function",
	},
	{
		menu = "Folder",
		kind = MiniIcons.get("lsp", "folder"),
		kind_hlgroup = "Function",
	},
	{
		menu = "EnumMember",
		kind = MiniIcons.get("lsp", "enummember"),
		kind_hlgroup = "Number",
	},
	{
		menu = "Constant",
		kind = MiniIcons.get("lsp", "constant"),
		kind_hlgroup = "Constant",
	},
	{
		menu = "Struct",
		kind = MiniIcons.get("lsp", "struct"),
		kind_hlgroup = "Type",
	},
	{
		menu = "Event",
		kind = MiniIcons.get("lsp", "event"),
		kind_hlgroup = "Constant",
	},
	{
		menu = "Operator",
		kind = MiniIcons.get("lsp", "operator"),
		kind_hlgroup = "Operator",
	},
	{
		menu = "TypeParameter",
		kind = MiniIcons.get("lsp", "typeparameter"),
		kind_hlgroup = "Type",
	},
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client == nil then
			return
		end

		if client:supports_method(methods.textDocument_completion) then
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end

			client.server_capabilities.completionProvider.triggerCharacters = chars

			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
				convert = function(item)
					local m = kind_icon[item.kind]
					return {
						abbr = item.label,
						kind = m.kind,
						-- menu = ("[%s]"):format(m.menu),
						menu = "",
						kind_hlgroup = m.kind_hlgroup,
					}
				end,
			})
		end
	end,
})

vim.lsp.enable("gopls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("nixd")
vim.lsp.enable("jsonls")
vim.lsp.enable("ts_ls") -- TODO: try vtsls
vim.lsp.enable("bashls")

-- vim.lsp.enable("pyrefly")
-- vim.lsp.enable("ty")
-- vim.lsp.enable("solidity_ls")
-- vim.lsp.enable("zls")
-- vim.lsp.enable("clangd")
-- vim.lsp.enable("ruff")
-- vim.lsp.enable("basedpyright")
-- vim.lsp.enable("ocamllsp")
-- vim.lsp.enable("terraformls") -- TODO: activate only if terraform-ls is installed
-- vim.lsp.enable("jdtls")
-- vim.lsp.enable("taplo")

local disabled_by_autocmd = false -- TODO: should this be global because of garbage collection?

vim.api.nvim_create_autocmd("InsertEnter", {
	-- group = vim.api.nvim_create_augroup("LspAttach", {}),
	desc = "Disable inlay hints when entering insert mode (if enabled)",
	pattern = "*",
	callback = function(event)
		vim.schedule(function()
			if not vim.lsp.inlay_hint.is_enabled() then
				return
			end

			vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
			disabled_by_autocmd = true
		end)
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	desc = "Enable inlay hints when leaving insert mode (if they were enabled)",
	group = vim.api.nvim_create_augroup("LspAttach", {}),
	pattern = "*",
	callback = function(event)
		vim.schedule(function()
			if not disabled_by_autocmd then
				return
			end

			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
			disabled_by_autocmd = false
		end)
	end,
})

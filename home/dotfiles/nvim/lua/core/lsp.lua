local methods = vim.lsp.protocol.Methods

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "vim.lsp.buf.definition()" })

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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client == nil then
			return
		end

		if client:supports_method(methods.textDocument_completion) then
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

		if client:supports_method(methods.textDocument_foldingRange) then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		if client:supports_method(methods.textDocument_inlineCompletion) then
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

		if client:supports_method(methods.textDocument_onTypeFormatting) then
			vim.lsp.on_type_formatting.enable(true, { client_id = ev.data.client_id })
		end
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client == nil then
			return
		end

		if client:supports_method(methods.textDocument_foldingRange) then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
	end,
})

vim.keymap.set("n", "<leader>ta", function()
	vim.lsp.enable("copilot", not vim.lsp.is_enabled("copilot"))
end, { desc = "Toggle copilot lsp" })

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

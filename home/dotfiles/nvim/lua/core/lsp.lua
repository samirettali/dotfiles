local methods = vim.lsp.protocol.Methods

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "vim.lsp.buf.definition()" })
-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
vim.keymap.set("n", "gS", function()
	vim.lsp.buf.workspace_symbol("")
end, { desc = "vim.lsp.buf.workspace_symbol()" })
-- vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
-- vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })

vim.keymap.set("n", "<leader>gS", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, { buffer = 0 })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

local kind_icon = {
	{ menu = "Text", kind = "󰦨", kind_hlgroup = "String" },
	{ menu = "Method", kind = "", kind_hlgroup = "Function" },
	{ menu = "Function", kind = "󰡱", kind_hlgroup = "Function" },
	{ menu = "Constructor", kind = "", kind_hlgroup = "Function" },
	{ menu = "Field", kind = "", kind_hlgroup = "@lsp.type.property" },
	{ menu = "Variable", kind = "", kind_hlgroup = "@variable" },
	{ menu = "Class", kind = "", kind_hlgroup = "Include" },
	{ menu = "Interface", kind = "", kind_hlgroup = "Type" },
	{ menu = "Module", kind = "", kind_hlgroup = "Exception" },
	{ menu = "Property", kind = "", kind_hlgroup = "@lsp.type.property" },
	{ menu = "Unit", kind = "󰊱", kind_hlgroup = "Number" },
	{ menu = "Value", kind = "", kind_hlgroup = "@variable" },
	{ menu = "Enum", kind = "", kind_hlgroup = "Number" },
	{ menu = "Keyword", kind = "", kind_hlgroup = "Keyword" },
	{ menu = "Snippet", kind = "", kind_hlgroup = "Keyword" },
	{ menu = "Color", kind = "", kind_hlgroup = "Keyword" },
	{ menu = "File", kind = "", kind_hlgroup = "Tag" },
	{ menu = "Reference", kind = "", kind_hlgroup = "Function" },
	{ menu = "Folder", kind = "󰣞", kind_hlgroup = "Function" },
	{ menu = "EnumMember", kind = "", kind_hlgroup = "Number" },
	{ menu = "Constant", kind = "", kind_hlgroup = "Constant" },
	{ menu = "Struct", kind = "", kind_hlgroup = "Type" },
	{ menu = "Event", kind = "", kind_hlgroup = "Constant" },
	{ menu = "Operator", kind = "", kind_hlgroup = "Operator" },
	{ menu = "TypeParameter", kind = "", kind_hlgroup = "Type" },
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client == nil then
			return
		end

		if client:supports_method(methods.textDocument_completion) then
			-- local chars = {}
			-- for i = 32, 126 do
			-- 	table.insert(chars, string.char(i))
			-- end
			--
			-- client.server_capabilities.completionProvider.triggerCharacters = chars

			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
				convert = function(item)
					local m = kind_icon[item.kind]
					return {
						abbr = item.label,
						kind = m.kind,
						menu = m.menu,
						kind_hlgroup = m.kind_hlgroup,
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
	local status = not vim.lsp.is_enabled("copilot")
	vim.lsp.enable("copilot", status)
	if status then
		vim.notify("Copilot enabled")
	else
		vim.notify("Copilot disabled")
	end
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

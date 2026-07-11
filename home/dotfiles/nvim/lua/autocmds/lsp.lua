local group = vim.api.nvim_create_augroup("Lsp", { clear = true })

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

vim.api.nvim_create_autocmd("LspAttach", { group = group, callback = on_lsp_attach })
vim.api.nvim_create_autocmd("LspDetach", { group = group, callback = on_lsp_detach })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
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

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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client == nil then
			return
		end

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
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

local methods = vim.lsp.protocol.Methods

-- TODO: this is not always working
local function custom_implementation_provider(bufnr)
	local telescope = require("telescope.builtin")

	return function()
		local params = vim.lsp.util.make_position_params()

		vim.lsp.buf_request(bufnr, methods.textDocument_implementation, params, function(err, result, ctx, config)
			if result == nil then
				return
			end

			local ft = vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr })

			-- In go code, I do not like to see any mocks for impls
			if ft == "go" then
				local new_result = vim.tbl_filter(function(v)
					return not string.find(v.uri, "mock_")
				end, result)

				if #new_result > 0 then
					result = new_result
				end
			end

			-- TODO: use telescope
			-- vim.lsp.handlers[methods.textDocument_implementation](err, result, ctx, config)
			telescope.lsp_implementations(err, result, ctx, config)
			vim.cmd([[normal! zz]])
		end)
	end
end

return {

	dependencies = {
		"nvim-telescope/telescope.nvim",
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
		"saghen/blink.cmp",
		{ "j-hui/fidget.nvim", config = true }, -- Show LSP loading status
	},
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")

		local augroup_lsp_user = vim.api.nvim_create_augroup("lsp_user", {})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = augroup_lsp_user,
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				if not client then
					error("LSP client not found")
					return
				end

				-- Example 1
				--   vim.opt.foldmethod = 'expr'
				-- if client:supports_method('textDocument/foldingRange') and vim.lsp.foldexpr then
				--   vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
				--   vim.opt.foldtext = 'v:lua.vim.lsp.foldtext()'
				-- elseif vim.treesitter.foldexpr then
				--   vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
				--   vim.opt.foldtext = ''
				-- else
				--   vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
				--   vim.opt.foldtext = ''
				-- end

				if client:supports_method(methods.textDocument_foldingRange) then
					local fold_opts = { scope = "local" }

					vim.api.nvim_set_option_value("foldmethod", "expr", fold_opts)
					vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", fold_opts)
					-- vim.api.nvim_set_option_value("foldtext", "v:lua.vim.lsp.foldtext()", fold_opts)
				end

				if client:supports_method(methods.textDocument_completion) then
					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
				end

				if client:supports_method(methods.textDocument_definition) then
					vim.opt_local.tagfunc = "v:lua.vim.lsp.tagfunc"
				end

				local function toggle_lsp_hints()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end

				local telescope = require("telescope.builtin")

				local default_opts = { buffer = args.buf }
				if client:supports_method(methods.textDocument_inlayHint) then
					vim.keymap.set("n", "<Leader>ti", toggle_lsp_hints, default_opts)
				end

				-- if client:supports_method(methods.textDocument_hover) then
				-- 	vim.keymap.set("n", "K", vim.lsp.buf.hover, default_opts)
				-- end

				if client:supports_method(methods.textDocument_definition) then
					-- vim.keymap.set("n", "gd", telescope.lsp_definitions, default_opts) -- telescope is not working right now
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, default_opts)
					vim.keymap.set("n", "GD", function()
						telescope.lsp_definitions({ jump_type = "vsplit" })
					end, default_opts)
				end

				if client:supports_method(methods.textDocument_declaration) then
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, default_opts)
				end
				if client:supports_method(methods.textDocument_typeDefinition) then
					vim.keymap.set("n", "gT", telescope.lsp_type_definitions, default_opts)
				end

				if client:supports_method(methods.textDocument_documentSymbol) then
					vim.keymap.set("n", "gs", telescope.lsp_document_symbols, default_opts)
				end

				if client:supports_method(methods.workspace_symbol) then
					vim.keymap.set("n", "gS", telescope.lsp_dynamic_workspace_symbols, default_opts)
				end

				if client:supports_method(methods.textDocument_codeAction) then
					vim.keymap.set("n", "ga", vim.lsp.buf.code_action, default_opts)
				end

				if client:supports_method(methods.textDocument_rename) then
					vim.keymap.set("n", "gr", vim.lsp.buf.rename, default_opts)
				end

				if client:supports_method(methods.textDocument_references) then
					vim.keymap.set("n", "gR", telescope.lsp_references)
				end

				if client:supports_method(methods.textDocument_references) then
					vim.keymap.set("n", "gR", telescope.lsp_references)
				end

				if client:supports_method(methods.textDocument_signatureHelp) then
					vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, default_opts)
				end

				if client:supports_method(methods.callHierarchy_incomingCalls) then
					vim.keymap.set("n", "gI", telescope.lsp_incoming_calls, default_opts)
				end

				if client:supports_method(methods.callHierarchy_outgoingCalls) then
					vim.keymap.set("n", "gO", telescope.lsp_outgoing_calls, default_opts)
				end

				-- if client:supports_method(methods.textDocument_diagnostic) then
				-- 	vim.keymap.set("n", "<leader>gd", telescope.diagnostics, default_opts)
				-- 	-- vim.keymap.set("n", "ds", vim.diagnostic.open_float, default_opts)
				--
				-- 	-- TODO: float is not working
				-- 	local next_opts = { count = 1, wrap = true, float = true }
				-- 	vim.keymap.set("n", "]d", function()
				-- 		vim.diagnostic.jump(next_opts)
				-- 	end, default_opts)
				--
				-- 	local prev_opts = { count = -1, wrap = true, float = true }
				-- 	vim.keymap.set("n", "[d", function()
				-- 		vim.diagnostic.jump(prev_opts)
				-- 	end, default_opts)
				-- end

				if client:supports_method(methods.textDocument_implementation, args.buf) then
					vim.keymap.set("n", "gi", telescope.lsp_implementations, default_opts)
				end

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("CustomLspHighlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = args.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = args.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("CustomLspHighlightDetach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "CustomLspHighlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})

		-- TODO: this is not working
		vim.api.nvim_create_autocmd("LspNotify", {
			callback = function(args)
				if args.data.method == methods.textDocument_didOpen then
					vim.lsp.foldclose("imports", vim.fn.bufwinid(args.buf))
				end
			end,
		})

		local augroup_completion = vim.api.nvim_create_augroup("lsp_completion", {})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = augroup_completion,
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client == nil then
					return
				end

				if client:supports_method(methods.textDocument_completion) then
					vim.cmd("setlocal tagfunc< omnifunc<")
				end
			end,
		})

		vim.diagnostic.config({
			virtual_text = {
				source = "if_many",
			},
			signs = false,
			underline = false,
			severity_sort = true,
			update_in_insert = false,
		})

		local servers = {
			gopls = {
				settings = {
					gopls = {
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						staticcheck = true,
						vulncheck = "Imports",
						-- gofumpt = true,
					},
				},
			},
			ts_ls = {
				filetypes = { "typescriptreact", "typescript" },
			},
			rust_analyzer = {
				settings = {
					checkOnSave = {
						command = "clippy",
					},
					flags = {
						debounce_text_changes = 200,
					},
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
						telemetry = {
							enable = false,
						},
						hint = {
							enable = true,
							arrayIndex = "enable",
							setType = true,
						},
					},
				},
			},
			solidity_ls = {
				cmd = { "vscode-solidity-server", "--stdio" },
			},
			nixd = true,
			zls = true,
			clangd = true,
			pyright = true,
			bashls = true,
			ocamllsp = true,
			terraformls = true, -- TODO: activate only if terraform-ls is installed or DOTFILES_PROFILE=work
			jsonls = true,
		}

		for name, cfg in pairs(servers) do
			if cfg == true then
				cfg = {}
			end

			-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local capabilities = require("blink.cmp").get_lsp_capabilities(cfg.capabilities)

			cfg = vim.tbl_deep_extend("force", {}, {
				capabilities = capabilities,
			}, cfg)

			lspconfig[name].setup(cfg)
		end

		-- Autoformatting Setup
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports", "gofumpt" },
				rust = { "rustfmt" },
				nix = { "alejandra" },
				bash = { "shellcheck" },
				javascript = { "prettierd" },
				python = { "isort", "black" },
				ocaml = { "ocamlformat" },
				cpp = { "clang-format" },
				cs = { "csharpier" },
				-- ["*"] = { "codespell" },
				-- ["_"] = { "trim_whitespace" }, -- if no formatter is found, use this
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				require("conform").format({
					bufnr = args.buf,
					lsp_fallback = true,
					quiet = true,
				})
			end,
		})

		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "revive", "golangcilint" },
			javascript = { "eslint_d" },
			cpp = { "clang-tidy", "cppcheck", "cpplint" },
		}

		-- TODO: does this need an autogroup?
		-- TODO: should lint be required for each usage?
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*.go", "*.js" },
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}

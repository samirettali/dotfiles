local methods = vim.lsp.protocol.Methods

local function custom_implementation_provider(bufnr)
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

			vim.lsp.handlers[methods.textDocument_implementation](err, result, ctx, config)
			vim.cmd([[normal! zz]])
		end)
	end
end

return {
	dependencies = {
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
		"SmiteshP/nvim-navic", -- LSP breadcrumbs
	},
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")

		local augroup_lsp_user = vim.api.nvim_create_augroup("lsp_user", {})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = augroup_lsp_user,
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client == nil then
					error("LSP client not found")
					return
				end

				if client.supports_method(methods.textDocument_completion) then
					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
				end

				if client.supports_method(methods.textDocument_definition) then
					vim.opt_local.tagfunc = "v:lua.vim.lsp.tagfunc"
				end

				if client.supports_method(methods.textDocument_documentSymbol) then
					local navic_present, navic = pcall(require, "nvim-navic")
					if navic_present then
						navic.attach(client, args.buf)
					end
				end

				local default_opts = { buffer = args.buf, remap = false }
				local function setup_lsp_mapping(mode, lhs, rhs, opts)
					if opts == nil then
						opts = {}
					end

					opts = vim.tbl_deep_extend("force", default_opts, opts)

					vim.keymap.set(mode, lhs, rhs, opts)
				end

				local function toggle_lsp_hints()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end

				if client.supports_method(methods.textDocument_inlayHint) then
					setup_lsp_mapping("n", "<Leader>ti", toggle_lsp_hints)
				end

				if client.supports_method(methods.textDocument_hover) then
					setup_lsp_mapping("n", "K", vim.lsp.buf.hover)
				end

				if client.supports_method(methods.textDocument_definition) then
					setup_lsp_mapping("n", "gd", vim.lsp.buf.definition)
				end
				if client.supports_method(methods.textDocument_declaration) then
					setup_lsp_mapping("n", "gD", vim.lsp.buf.declaration)
				end
				if client.supports_method(methods.textDocument_typeDefinition) then
					setup_lsp_mapping("n", "gT", vim.lsp.buf.type_definition)
				end

				if client.supports_method(methods.textDocument_documentSymbol) then
					setup_lsp_mapping("n", "gs", vim.lsp.buf.document_symbol)
				end

				if client.supports_method(methods.workspace_symbol) then
					setup_lsp_mapping("n", "gS", vim.lsp.buf.workspace_symbol)
				end

				if client.supports_method(methods.textDocument_codeAction) then
					setup_lsp_mapping("n", "ga", vim.lsp.buf.code_action)
				end

				if client.supports_method(methods.textDocument_rename) then
					setup_lsp_mapping("n", "gr", vim.lsp.buf.rename)
				end

				if client.supports_method(methods.textDocument_signatureHelp) then
					setup_lsp_mapping("i", "<C-h>", vim.lsp.buf.signature_help)
				end

				if client.supports_method(methods.callHierarchy_incomingCalls) then
					setup_lsp_mapping("n", "gI", vim.lsp.buf.incoming_calls)
				end

				if client.supports_method(methods.callHierarchy_outgoingCalls) then
					setup_lsp_mapping("n", "gO", vim.lsp.buf.outgoing_calls)
				end

				if client.supports_method(methods.textDocument_diagnostic) then
					setup_lsp_mapping("n", "ds", vim.diagnostic.open_float)

					local next_opts = { count = 1, wrap = true, float = true }
					setup_lsp_mapping("n", "]d", function()
						vim.diagnostic.jump(next_opts)
					end)

					local prev_opts = { count = -1, wrap = true, float = true }
					setup_lsp_mapping("n", "[d", function()
						vim.diagnostic.jump(prev_opts)
					end)
				end

				if client.supports_method(methods.textDocument_implementation) then
					vim.keymap.set("n", "gi", custom_implementation_provider(args.buf), default_opts)
				end
			end,
		})

		-- TODO: is this needed?
		local augroup_completion = vim.api.nvim_create_augroup("lsp_completion", {})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = augroup_completion,
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client == nil then
					return
				end

				if client.supports_method(methods.textDocument_completion) then
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
			-- golangci_lint_ls = {
			--     capabilities = capabilities,
			--     command = {
			--         "golangci-lint",
			--         "run",
			--         "--enable-all",
			--         "--disable",
			--         "lll",
			--         "--out-format",
			--         "json",
			--         "--issues-exit-code=1",
			--     },
			-- },
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
						analyses = {
							assign = true,
							deepequalerrors = true,
							fieldalignment = true,
							nilness = true,
							shadow = true,
							unreachable = true,
							unusedparams = true,
							unusedvariable = true,
							unusedwrite = true,
							useany = true,
						},
						staticcheck = true,
						vulncheck = "Imports",
						-- gofumpt = true,
					},
				},
			},
			tsserver = {
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
			csharp_ls = true,
			clangd = true,
			pyright = true,
		}

		local capabilities = nil
		if pcall(require, "cmp_nvim_lsp") then
			capabilities = require("cmp_nvim_lsp").default_capabilities()
		end

		for name, cfg in pairs(servers) do
			if cfg == true then
				cfg = {}
			end
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
				rust = { "rustfmt", lsp_format = "fallback" }, -- TODO: what is lsp_format?
				-- Use the "*" filetype to run formatters on all filetypes.
				-- ["*"] = { "codespell" },
				-- Use the "_" filetype to run formatters on filetypes that don't
				-- have other formatters configured.
				-- ["_"] = { "trim_whitespace" },
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
			go = { "revive" },
		}

		-- TODO: does this need an autogroup?
		-- TODO: should lint be required for each usage?
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*.go" },
			callback = lint.try_lint,
		})
	end,
}

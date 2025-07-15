local methods = vim.lsp.protocol.Methods

local function disable_default_keymaps()
	local default_keymaps = {
		"grn",
		"gra",
		"grr",
		"gri",
		"grt",
		"gO",
	}

	for _, keymap in ipairs(default_keymaps) do
		pcall(function()
			vim.keymap.del("n", keymap)
		end)
	end
end

return {
	dependencies = {
		"saghen/blink.cmp",
	},
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		disable_default_keymaps()

		local lspconfig = require("lspconfig")

		-- TODO: map vim.lsp.buf.document_symbol
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
		vim.keymap.set("n", "gr", vim.lsp.buf.rename, { desc = "vim.lsp.buf.rename()" })
		vim.keymap.set("n", "gR", vim.lsp.buf.references, { desc = "vim.lsp.buf.references()" })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "vim.lsp.buf.implementation()" })

		vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls)
		vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls)

		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "vim.lsp.buf.type_definition()" })
		vim.keymap.set({ "n", "x" }, "ga", vim.lsp.buf.code_action, { desc = "vim.lsp.buf.code_action()" })

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
						analyses = {
							shadow = true,
						},
						codelenses = {
							test = true,
						},
						gofumpt = true,
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
					},
				},
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
			wgsl_analyzer = {},
			lua_ls = {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
								-- TODO: enable this only on mac and remove hardcoded path
								"/Users/s.ettali/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
							},
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
			ts_ls = {},
			solidity_ls = {},
			nixd = {},
			zls = {},
			clangd = {},
			ruff = {
				settings = {
					python = {
						interpreter = { vim.g.venv_detector_python_path },
					},
				},
			},
			basedpyright = {
				settings = {
					python = {
						pythonPath = vim.g.venv_detector_python_path,
					},
				},
			},
			bashls = {},
			ocamllsp = {},
			terraformls = {}, -- TODO: activate only if terraform-ls is installed or DOTFILES_PROFILE=work
			jdtls = {},
			jsonls = {},
			taplo = {},
		}

		for name, cfg in pairs(servers) do
			-- TODO: debug this and understand if it's needed
			local capabilities = require("blink.cmp").get_lsp_capabilities(cfg.capabilities)

			cfg = vim.tbl_deep_extend("force", {}, {
				capabilities = capabilities,
			}, cfg)

			lspconfig[name].setup(cfg)
		end

		vim.lsp.enable("ty")
	end,
}

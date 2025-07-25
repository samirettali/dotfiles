local utils = require("core.utils")
local disabled_by_autocmd = false -- TODO: should this be global because of garbage collection?

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
		-- disable_default_keymaps()

		local lspconfig = require("lspconfig")

		-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
		-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
		-- vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "vim.lsp.buf.references()" })
		-- vim.keymap.set("n", "gR", vim.lsp.buf.rename, { desc = "vim.lsp.buf.rename()" })
		-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "vim.lsp.buf.implementation()" })
		-- vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, { desc = "vim.lsp.buf.document_symbol()" })
		-- vim.keymap.set("n", "gS", function()
		-- 	vim.lsp.buf.workspace_symbol()
		-- end, { desc = "vim.lsp.buf.workspace_symbol()" })

		-- vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
		-- vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })

		-- vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { desc = "vim.lsp.buf.type_definition()" })
		-- vim.keymap.set({ "n", "x" }, "ga", vim.lsp.buf.code_action, { desc = "vim.lsp.buf.code_action()" })

		vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
		vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

		vim.keymap.set("n", "<localleader>v", function()
			local config = not vim.diagnostic.config().virtual_lines
			vim.diagnostic.config({ virtual_lines = config })
		end, { desc = "Toggle diagnostic virtual lines" })

		vim.keymap.set("n", "<leader>ti", utils.toggle_inlay_hints, { desc = "Toggle inlay hints" })

		vim.api.nvim_create_autocmd("InsertEnter", {
			-- group = vim.api.nvim_create_augroup("LspAttach", {}),
			pattern = "*",
			callback = function(event)
				vim.schedule(function()
					-- check if they are enabled
					if not vim.lsp.inlay_hint.is_enabled() then
						return
					end

					vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
					disabled_by_autocmd = true
				end)
			end,
		})

		vim.api.nvim_create_autocmd("InsertLeave", {
			group = vim.api.nvim_create_augroup("LspAttach", {}),
			pattern = "*",
			callback = function(event)
				vim.schedule(function()
					if disabled_by_autocmd then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
						disabled_by_autocmd = false
					end
				end)
			end,
		})

		local function on_jump(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
				source = "if_many",
			})
		end

		vim.diagnostic.config({
			jump = { on_jump = on_jump },
			float = {
				header = "",
				scope = "cursor",
				source = "if_many",
			},
			virtual_lines = false,
			underline = true,
			severity_sort = true,
			-- signs = false, -- TODO
			text = {
				[vim.diagnostic.severity.ERROR] = "E",
				[vim.diagnostic.severity.WARN] = "W",
				[vim.diagnostic.severity.HINT] = "H",
				[vim.diagnostic.severity.INFO] = "I",
			},
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
			ts_ls = {}, -- TODO: try vtsls
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
		vim.lsp.enable("pyrefly")
	end,
}

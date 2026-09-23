local ignored = {
	"ST1005", -- error strings should not be capitalized
	"ST1003", -- method ... should be ...
	"any", -- interface{} can be replaced with any
	"shadow",
}

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl", "gosum" },
	root_markers = { "go.mod", "go.work", ".git" },
	settings = {
		gopls = {
			gofumpt = true,
			codelenses = {
				generate = true,
				regenerate_cgo = true,
				run_govulncheck = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			hints = {
				assignVariableTypes = false,
				compositeLiteralFields = false,
				compositeLiteralTypes = false,
				constantValues = false,
				functionTypeParameters = false,
				parameterNames = false,
				rangeVariableTypes = false,
			},
			-- Every other analyzer is already on by default.
			analyses = { shadow = true },
			usePlaceholders = true,
			staticcheck = true,
			directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			semanticTokens = true,
		},
	},
	on_attach = function(_, bufnr)
		-- Lenses run a test, go generate or go mod tidy through the built-in grx.
		vim.lsp.codelens.enable(true, { bufnr = bufnr })
	end,
	handlers = {
		["textDocument/publishDiagnostics"] = function(err, result, ctx)
			local uri = result.uri or ""

			if uri:match("%.gen%.go$") then
				result.diagnostics = vim.tbl_filter(function(d)
					return not vim.tbl_contains(ignored, d.source)
				end, result.diagnostics)
			end

			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
}

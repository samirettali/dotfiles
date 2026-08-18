vim.diagnostic.config({ signs = false })

vim.lsp.enable({
	"bashls",
	"clangd",
	"gopls",
	"golangci_lint_ls",
	"lua_ls",
	"stylua",
	"jsonls",
	"ts_ls", -- TODO: try vtsls
	"eslint",
	"nixd",
	"roslyn_ls",
	"rust_analyzer",
	"solidity_ls",
	"yamlls",
	"buf_ls",
	"copilot",
	"basedpyright",
	"ruff",
	"harper",
	"dartls",
})


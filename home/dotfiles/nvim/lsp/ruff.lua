--- An extremely fast Python linter and code formatter, written in Rust.
---
--- Hover is disabled so that `basedpyright` remains the single source of
--- hover information: running both leaves two providers answering the same
--- request, and ruff's answer is the less useful of the two.
---@type vim.lsp.Config
return {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
	settings = {},
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
}

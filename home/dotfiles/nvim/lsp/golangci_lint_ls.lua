---@type vim.lsp.Config
return {
	cmd = { "golangci-lint-langserver" },
	filetypes = { "go", "gomod" },
	init_options = {
		command = {
			"golangci-lint",
			"run",
			-- disable all output formats that might be enabled by the users .golangci.yml
			"--output.text.path=",
			"--output.tab.path=",
			"--output.html.path=",
			"--output.checkstyle.path=",
			"--output.junit-xml.path=",
			"--output.teamcity.path=",
			"--output.sarif.path=",
			-- disable stats output
			"--show-stats=false",
			-- enable JSON output to be used by the language server
			"--output.json.path=stdout",
		},
	},
	root_markers = {
		".golangci.yml",
		".golangci.yaml",
		".golangci.toml",
		".golangci.json",
		"go.work",
		"go.mod",
		".git",
	},
}

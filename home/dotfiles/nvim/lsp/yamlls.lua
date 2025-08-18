return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
	root_markers = { ".git" },
	settings = {
		redhat = { telemetry = { enabled = false } },
	},
	on_init = function(client)
		-- https://github.com/redhat-developer/yaml-language-server/issues/486
		client.server_capabilities.documentFormattingProvider = true
	end,
}

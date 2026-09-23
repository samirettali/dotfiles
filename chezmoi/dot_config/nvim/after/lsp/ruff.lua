-- Hover is disabled so that basedpyright remains the single source of hover
-- information: running both leaves two providers answering the same request,
-- and ruff's answer is the less useful of the two.
return {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
}

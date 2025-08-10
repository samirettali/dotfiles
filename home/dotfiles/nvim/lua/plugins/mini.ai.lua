return {
	"echasnovski/mini.ai",
	dependencies = { "echasnovski/mini.extra" },
	event = { "BufReadPre", "BufNewFile" },
	version = false,
	config = function()
		local gen_ai_spec = require("mini.extra").gen_ai_spec
		require("mini.ai").setup({
			custom_textobjects = {
				e = gen_ai_spec.buffer(),
				D = gen_ai_spec.diagnostic(),
				I = gen_ai_spec.indent(),
				L = gen_ai_spec.line(),
				N = gen_ai_spec.number(),
			},
		})
	end,
}

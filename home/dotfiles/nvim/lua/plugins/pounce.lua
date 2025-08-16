return {
	"rlane/pounce.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		increase_cmd_height_if_zero = false,
	},

	keys = {
		{
			"<localleader>f",
			function()
				require("pounce").pounce({})
			end,
			desc = "Pounce",
		},
		-- TODO
		-- map("n", "S", function()
		-- 	require("pounce").pounce({ do_repeat = true })
		-- end)
		-- map("x", "s", function()
		-- 	require("pounce").pounce({})
		-- end)
		-- map("o", "gs", function()
		-- 	require("pounce").pounce({})
		-- end)
		-- map("n", "S", function()
		-- 	require("pounce").pounce({ input = { reg = "/" } })
		-- end)
	},
}

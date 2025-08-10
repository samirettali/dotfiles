return {
	"Goose97/timber.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		log_templates = {
			time_start = {
				lua = [[local _start = os.time()]],
				go = [[_start := time.Now()]],
			},
			time_end = {
				lua = [[print("Elapsed time: " .. tostring(os.time() - _start) .. " seconds")]],
				go = [[fmt.Printf("Elapsed time: %d ms\n", time.Since(_start).Milliseconds())]],
			},
		},
	},
	keys = {
		{
			"glt",
			function()
				require("timber.actions").insert_log({
					templates = { before = "time_start", after = "time_end" },
					position = "surround",
				})
			end,
			desc = "Timber: insert timed log",
		},
	},
}

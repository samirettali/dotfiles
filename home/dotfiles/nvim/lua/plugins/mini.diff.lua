return {
	"nvim-mini/mini.diff",
	version = false,
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		view = {
			style = "sign",
			signs = { add = "┃", change = "┃", delete = "┃" },
		},
		delay = {
			text_change = 0,
		},
	},
}

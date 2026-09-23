return {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
			cargo = {
				features = "all",
			},
		},
	},
}

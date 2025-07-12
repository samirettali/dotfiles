return {
	"rmagatti/auto-session",
	config = function()
		-- TODO: integrate with snacks.nvim
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
		require("auto-session").setup()
	end,
}

return {
	"sQVe/sort.nvim",
	config = function()
		require("sort").setup()
		vim.cmd([[
                nnoremap <silent> go <Cmd>Sort<CR>
                vnoremap <silent> go <Esc><Cmd>Sort<CR>
                "nnoremap <silent> go" vi"<Esc><Cmd>Sort<CR>
                "nnoremap <silent> go' vi'<Esc><Cmd>Sort<CR>
                "nnoremap <silent> go( vi(<Esc><Cmd>Sort<CR>
                "nnoremap <silent> go[ vi[<Esc><Cmd>Sort<CR>
                "nnoremap <silent> gop vip<Esc><Cmd>Sort<CR>
                "nnoremap <silent> go{ vi{<Esc><Cmd>Sort<CR>
            ]])
	end,
}

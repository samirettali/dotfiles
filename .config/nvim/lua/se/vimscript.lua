vim.api.nvim_exec([[
if exists('##TextYankPost')
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
    augroup END
endif
]], false)

vim.api.nvim_exec([[
    autocmd VimResized * :wincmd =
]], false)

vim.api.nvim_exec([[
function! ShaBang(portable, permission, RemExt)
let shells = {
        \    'awk': "awk",
        \     'sh': "bash",
        \     'hs': "runhaskell",
        \     'jl': "julia",
        \    'lua': "lua",
        \    'mak': "make",
        \      'm': "octave",
        \     'pl': "perl",
        \    'php': "php",
        \     'py': "python3",
        \      'r': "Rscript",
        \     'rb': "ruby",
        \  'scala': "scala",
        \    'tcl': "tclsh",
        \     'tk': "wish",
        \    }

let extension = expand("%:e")

if has_key(shells,extension)
  let fileshell = shells[extension]
  if a:portable
    let line =  "#!/usr/bin/env " . fileshell
  else
    let line = "#!" . system("which " . fileshell)
  endif
  0put = line
  if a:permission
    :autocmd BufWritePost * :autocmd VimLeave * :!chmod u+x %
  endif
  if a:RemExt
    :autocmd BufWritePost * :autocmd VimLeave * :!mv % "%:p:r"
  endif
  call cursor(2, 0)
endif

endfunction

autocmd BufNewFile *.* :call ShaBang(1,1,0)
]], false)


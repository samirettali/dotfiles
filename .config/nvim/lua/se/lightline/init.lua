vim.g.lightline = {
   colorscheme = 'moonfly',
   component_function = {
       gitbranch = 'fugitive#head'
   },
   active = {
       left = { { 'mode', 'paste' },
               { 'readonly', 'modified' } },
       right = { {'lineinfo', 'percent', 'gitbranch', 'filetype' } }
   },
 }

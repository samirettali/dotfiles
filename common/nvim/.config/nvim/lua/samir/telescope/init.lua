local actions = require('telescope.actions')

require('telescope').setup{
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter,

    file_previewr   = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewr   = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewr = require('telescope.previewers').vim_buffer_qflist.new,

    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    file_ignore_patterns = {"node_modules", "docker"},
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    }
  }
}

require('telescope').load_extension('fzy_native')

map('n', '<C-f>',      '<Cmd>Telescope find_files<CR>')
map('n', '<C-b>',      '<Cmd>Telescope buffers<CR>')
map('n', '<C-g>',      '<Cmd>Telescope live_grep<CR>')

map('n', '<Leader>fR', '<Cmd> lua require("telescope.builtin")["lsp_references"]()<CR>', { noremap = true, silent = true})
map('n', '<Leader>fS', '<Cmd> lua require("telescope.builtin")["lsp_document_symbols"]()<CR>', { noremap = true, silent = true})
map('n', '<Leader>fs', '<Cmd> lua require("telescope.builtin")["lsp_workspace_symbols"]()<CR>', { noremap = true, silent = true})
map('n', '<Leader>fd', '<Cmd> lua require("telescope.builtin")["lsp_workspace_diagnostics"]()<CR>', { noremap = true, silent = true})

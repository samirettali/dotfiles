require('telescope').setup{
  defaults = {
    prompt_position = "bottom",
    prompt_prefix = ">",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    color_devicons = true,
    file_ignore_patterns = {"node_modules", "docker"},
  }
}

map('n', '<C-f>', '<Cmd>Telescope find_files<CR>')
-- local functions = {}

-- functions.show_diagnostics = function(opts)
  -- opts = opts or {}
  -- vim.lsp.diagnostic.set_loclist({open_loclist = false})
  -- require'telescope.builtin'.loclist(opts)
-- end

-- return functions

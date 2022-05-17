local present, telescope = pcall(require, "telescope")

if not present then
   return
end

local actions = require("telescope.actions")
local utils = require("core.utils")

local map = utils.map

local options = {
  defaults = {
    vimgrep_arguments = {
       "rg",
       "--color=never",
       "--no-heading",
       "--with-filename",
       "--line-number",
       "--column",
       "--smart-case",
    },

    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    color_devicons = true,
    entry_prefix = "  ",
    file_ignore_patterns = {"node_modules", "docker", "%.mmdb", "vendor"},
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    initial_mode = "insert",
    layout_strategy = "horizontal",
    path_display = { "truncate" },
    prompt_prefix = "   ",
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    selection_caret = "  ",
    selection_strategy = "reset",
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    sorting_strategy = "ascending",
    use_less = true,
    winblend = 0,
    mappings = {
       n = { ["q"] = require("telescope.actions").close },
    },
    layout_strategy = "horizontal",
    layout_config = {
       horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.8,
       },
       vertical = {
          mirror = false,
       },
       width = 0.87,
       height = 0.80,
       preview_cutoff = 120,
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    }
  }
}

telescope.setup{options}

map("n", "<C-f>", "<Cmd>Telescope find_files<CR>")
map("n", "<C-q>", "<Cmd>Telescope lsp_workspace_diagnostics<CR>")
map("n", "<C-s>", "<Cmd>Telescope lsp_document_symbols<CR>")
map("n", "<C-w>", "<Cmd>Telescope lsp_workspace_symbols<CR>")
map("n", "<C-b>", "<Cmd>Telescope buffers<CR>")
map("n", "<C-g>", "<Cmd>Telescope live_grep<CR>")

map("n", "<Leader>fR", "<Cmd> lua require('telescope.builtin')['lsp_references']()<CR>", { noremap = true, silent = true})
map("n", "<Leader>fS", "<Cmd> lua require('telescope.builtin')['lsp_document_symbols']()<CR>", { noremap = true, silent = true})
map("n", "<Leader>fs", "<Cmd> lua require('telescope.builtin')['lsp_workspace_symbols']()<CR>", { noremap = true, silent = true})
map("n", "<Leader>fd", "<Cmd> lua require('telescope.builtin')['lsp_workspace_diagnostics']()<CR>", { noremap = true, silent = true})

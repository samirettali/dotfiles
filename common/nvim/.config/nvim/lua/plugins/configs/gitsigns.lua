local present, esp_signature = pcall(require, "lsp_signature")

if not present then
    return
end

local options = {
   bind = true,
   doc_lines = 0,
   floating_window = true,
   fix_pos = true,
   hint_enable = true,
   hint_prefix = " ",
   hint_scheme = "String",
   hi_parameter = "Search",
   max_height = 22,
   max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
   handler_opts = {
       border = "single", -- double, single, shadow, none
   },
   zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
   padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc

   igncolumn = true,
   numhl      = false,
   linehl     = false,
   word_diff  = false,

   attach_to_untracked = true,
   current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
   current_line_blame_opts = {
     virt_text = true,
     virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
     delay = 1000,
     ignore_whitespace = false,
   },
   current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
   sign_priority = 6,
   update_debounce = 100,
   status_formatter = nil, -- Use default
   max_file_length = 40000,
   preview_config = {
     -- Options passed to nvim_open_win
     border = 'single',
     style = 'minimal',
     relative = 'cursor',
     row = 0,
     col = 1
   },
   yadm = {
     enable = false
   },

   keymaps = {
     -- Default keymap options
     noremap = true,
     buffer = true,

     ['n ]h'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
     ['n [h'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

     ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
     ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
     ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
     ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
     ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
   },
   watch_gitdir = {
     interval = 1000,
     follow_files = true
   },
}
lsp_signature.setup(options)

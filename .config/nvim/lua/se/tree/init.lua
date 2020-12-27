
map('n', '<C-o>', ':LuaTreeToggle<CR>')
map('n', '<Leader>n', ':LuaTreeFindFile<CR>')

vim.g.lua_tree_allow_resize = 1
vim.g.lua_tree_auto_close = 1
vim.g.lua_tree_follow = 1
vim.g.lua_tree_git_hl = 1
vim.g.lua_tree_hide_dotfiles = 1
vim.g.lua_tree_ignore = { '.git', 'node_modules', '.cache' }
vim.g.lua_tree_root_folder_modifier = ':~'
vim.g.lua_tree_side = 'left'
vim.g.lua_tree_tab_open = 1
vim.g.lua_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    icons = 1,
}

vim.g.lua_tree_icons = {
    default = '  ',
    folder = {default = '', open = ''},
}
-- highlight link LuaTreeFolderName NERDTreeDir
-- highlight link LuaTreeSpecialFile Normal
-- " edit_tab = '<C-t>',
vim.g.lua_tree_bindings = {
    edit = { '<CR>', 'o' },
    edit_vsplit = '<C-v>',
    edit_split = '<C-x>',
    toggle_ignored = 'I',
    toggle_dotfiles = 'H',
    refresh = 'R',
    preview = '<Tab>',
    cd = '<C-]>',
    create = 'a',
    remove = 'd',
    rename = 'r',
    cut = 'x',
    copy = 'c',
    paste = 'p',
    prev_git_item = '[c',
    next_git_item = ']c',
}

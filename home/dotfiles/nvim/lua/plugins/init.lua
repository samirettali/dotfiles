local plugins = {
    "tpope/vim-repeat",                           -- Repeat plugin mappings with .
    "tommcdo/vim-exchange",                       -- Exchange two objects
    "sindrets/diffview.nvim",                     -- Improve diff view
    "tpope/vim-fugitive",                         -- Git wrapper
    "stevearc/dressing.nvim",                     -- Better UI selectors and inputs
    "tpope/vim-eunuch",                           -- UNIX commands inside neovim
    "rhysd/committia.vim",                        -- Better commit editing
    "tpope/vim-surround",                         -- Add surround object for editing
    { "j-hui/fidget.nvim",           opts = {} }, -- Show LSP loading status
    { "stevearc/oil.nvim",           opts = {} }, -- File explorer
    { "tzachar/highlight-undo.nvim", opts = {} }, -- Highlight undo and redo regions
    { "norcalli/nvim-colorizer.lua", opts = {} },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<C-t>", ":NvimTreeToggle<CR>", { silent = true })
        end,
    },
    {
        "rhysd/git-messenger.vim",
        config = function()
            vim.g.git_messenger_include_diff = "current"
            vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
        end
    },
    {
        -- Replace word under cursor
        "wincent/scalpel",
        config = function()
            vim.keymap.set("n", "<Leader>s", "<Plug>(Scalpel)")
        end,
    },
    {
        "chentoast/marks.nvim",
        opts = { builtin_marks = { ".", "<", ">", "^" } }
    },
}

require("lazy").setup {
    spec = {
        plugins,
        { import = "plugins.configs" },
    },
    defaults = {
        lazy = false,
    },
    change_detection = {
        enabled = true,
        notify = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "2html_plugin",
                "editorconfig",
                "getscript",
                "getscriptPlugin",
                "gzip",
                "logiPat",
                "man",
                "matchit",
                "matchparen",
                "rrhelper",
                "spellfile",
                "spellfile_plugin",
                "tar",
                "tarPlugin",
                "tohtml",
                "tutor",
                "vimball",
                "vimballPlugin",
                "zip",
                "zipPlugin",
            },
        },
    }
}

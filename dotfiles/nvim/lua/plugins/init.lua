local utils = require("core.utils")
local plugins = {
    "rhysd/committia.vim", -- Better commit editing
    {
        "rhysd/git-messenger.vim",
        config = function()
            vim.g.git_messenger_include_diff = "current"
            vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
        end
    },
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
            vim.keymap.set('n', '<Leader>k', 'gcip', {
                remap = true,
                desc = "Toggle paragraph comments"
            })
        end
    },
    "tpope/vim-surround", -- Add surround object for editing
    {
        "numToStr/Navigator.nvim",
        config = function()
            local navigator = require("Navigator")
            navigator.setup()
            vim.keymap.set({ "n", "t" }, "<C-h>", navigator.left)
            vim.keymap.set({ "n", "t" }, "<C-l>", navigator.right)
            vim.keymap.set({ "n", "t" }, "<C-k>", navigator.up)
            vim.keymap.set({ "n", "t" }, "<C-j>", navigator.down)
        end
    },
    {
        -- Replace word under cursor
        "wincent/scalpel",
        config = function()
            vim.keymap.set("n", "<Leader>s", "<Plug>(Scalpel)", { remap = false, silent = true })
        end,
    },
    {
        "chentoast/marks.nvim",
        opts = { builtin_marks = { ".", "<", ">", "^" } }
    },
    {
        "j-hui/fidget.nvim",
        opts = {}
    },
    "tpope/vim-repeat",     -- Repeat plugin mappings with .
    "tommcdo/vim-exchange", -- Exchange two objects
    "sindrets/diffview.nvim",
    "github/copilot.vim",
    "tpope/vim-fugitive",     -- Git wrapper
    "stevearc/dressing.nvim", -- Better UI selectors and inputs
    "tpope/vim-eunuch",       -- UNIX commands inside neovim
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disabled_filetypes = utils.plugin_filetypes,
            disabled_keys = { "j", "k" },
        }
    },
    {
        "nat-418/boole.nvim",
        config = function()
            require('boole').setup({
                mappings = {
                    increment = '<C-\'>',
                    decrement = '<C-;>'
                },
            })
        end
    },
    { "stevearc/oil.nvim", opts = {} }
    -- Notable mentions
    -- "aaronhallaert/advanced-git-search.nvim" -- Use telescope to search through git
    -- "wellle/targets.vim" -- Add more targets for commands
    -- "folke/todo-comments.nvim"
    -- "ultimate-autopair.nvim"
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
        -- cache = {
        --     enabled = true,
        -- },
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

local plugins = {
    "tpope/vim-repeat",                           -- Repeat plugin mappings with .
    "tommcdo/vim-exchange",                       -- Exchange two objects
    "sindrets/diffview.nvim",                     -- Improve diff view
    "tpope/vim-eunuch",                           -- UNIX commands inside neovim
    "rhysd/committia.vim",                        -- Better commit editing
    "tpope/vim-surround",                         -- Add surround object for editing
    "github/copilot.vim",                         -- Copilot
    "SmiteshP/nvim-navic",                        -- LSP breadcrumbs
    { "j-hui/fidget.nvim",       config = true }, -- Show LSP loading status
    { "stevearc/oil.nvim",       config = true }, -- File explorer
    { "laytan/cloak.nvim",       config = true }, -- Hide secrets in .env files
    { "lewis6991/gitsigns.nvim", config = true }, -- Git signs integration
    { "numToStr/Comment.nvim",   config = true }, -- Comment toggler
    {
        "folke/persistence.nvim",                 -- Session manager
        config = true,
        event = "BufReadPre"
    },
    {
        "rhysd/git-messenger.vim",
        config = function()
            vim.g.git_messenger_include_diff = "current"
            vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
        end
    },
    {
        "nat-418/boole.nvim",
        config = {
            mappings = {
                increment = '<C-\'>',
                decrement = '<C-;>'
            },
        }
    }
}

require("lazy").setup {
    install = {
        missing = true,
        colorscheme = { "moonfly", "habamax" },
    },
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

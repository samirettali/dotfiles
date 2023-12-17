local utils = require("core.utils")
local plugins = {
    {
        "chentoast/marks.nvim",
        opts = { builtin_marks = { ".", "<", ">", "^" } }
    },
    { "j-hui/fidget.nvim", opts = {} },
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disable_mouse = false,
            disabled_filetypes = utils.plugin_filetypes,
            restriction_mode = "hint",
        }
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
    },
    { "stevearc/oil.nvim", opts = {} },
    "tpope/vim-repeat",     -- Repeat plugin mappings with .
    "tommcdo/vim-exchange", -- Exchange two objects
    "sindrets/diffview.nvim",
    "github/copilot.vim",
    "tpope/vim-fugitive",     -- Git wrapper
    "stevearc/dressing.nvim", -- Better UI selectors and inputs
    "tpope/vim-eunuch",       -- UNIX commands inside neovim
    "rhysd/committia.vim",    -- Better commit editing
    "tpope/vim-surround",     -- Add surround object for editing
    -- Notable mentions
    -- "aaronhallaert/advanced-git-search.nvim" -- Use telescope to search through git
    -- "wellle/targets.vim" -- Add more targets for commands
    -- "folke/todo-comments.nvim"
    -- "ultimate-autopair.nvim"
}

local utils = require("core.utils")
local plugins = {
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
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            disable_mouse = false,
            disabled_filetypes = utils.plugin_filetypes,
            restriction_mode = "hint",
        }
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
    },
    { "preservim/nerdtree" },
    { "j-hui/fidget.nvim",           opts = {} }, -- Show LSP loading status
    { "stevearc/oil.nvim",           opts = {} }, -- File explorer
    { "tzachar/highlight-undo.nvim", opts = {} }, -- Highlight undo and redo regions
    "lukas-reineke/indent-blankline.nvim",        -- Show indentation lines
    "tpope/vim-repeat",                           -- Repeat plugin mappings with .
    "tommcdo/vim-exchange",                       -- Exchange two objects
    "sindrets/diffview.nvim",                     -- Improve diff view
    "github/copilot.vim",                         -- Github Copilot
    "tpope/vim-fugitive",                         -- Git wrapper
    "stevearc/dressing.nvim",                     -- Better UI selectors and inputs
    "tpope/vim-eunuch",                           -- UNIX commands inside neovim
    "rhysd/committia.vim",                        -- Better commit editing
    "tpope/vim-surround",                         -- Add surround object for editing
    -- Notable mentions
    -- "aaronhallaert/advanced-git-search.nvim" -- Use telescope to search through git
    -- "wellle/targets.vim" -- Add more targets for commands
    -- "folke/todo-comments.nvim"
    -- "ultimate-autopair.nvim"
    -- "Wansmer/treesj"
    -- "bennypowers/splitjoin.nvim
    -- "aarondiel/spread.nvim
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

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
    "tpope/vim-surround",   -- Add surround object for editing
    "chrisbra/Recover.vim", -- Show diff of a recovered swap file
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
    "tpope/vim-repeat",     -- Repeat plugin mappings with .
    "tommcdo/vim-exchange", -- Exchange two objects
    "sindrets/diffview.nvim",
    {
        "bluz71/vim-nightfly-colors",
        config = function()
            vim.g.nightflyWinSeparator = 2
            vim.g.nightflyCursorColor = true
            vim.g.nightflyItalics = false
            vim.g.nightflyUnderlineMatchParen = true
            vim.cmd.colorscheme("moonfly")
        end
    },
    -- Notable mentions
    -- "aaronhallaert/advanced-git-search.nvim" -- Use telescope to search through git
    -- "stevearc/dressing.nvim" -- Better UI selectors and inputs
    -- "wellle/targets.vim" -- Add more targets for commands
    -- b0o/incline.nvim -- Floating winbar like
    "sainnhe/sonokai",
    "rebelot/kanagawa.nvim",
    { 'rose-pine/neovim', name = 'rose-pine' },
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
                "netrw",
                "netrwFileHandlers",
                "netrwPlugin",
                "netrwSettings",
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

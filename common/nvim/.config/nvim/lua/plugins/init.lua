local utils = require("core.utils")

local function require_config(name)
    local path = "plugins.configs." .. name
    local result, err = pcall(require, path)

    if not result then
        vim.notify("could not load config for " .. name .. "\n" .. err, vim.lsp.log_levels.ERROR)
    end
end

local plugins = {
    -- Git
    {
        -- Better commit editing
        "rhysd/committia.vim"
    },
    {
        "rhysd/git-messenger.vim",
        keys = "<Plug>(git-messenger)",
        config = function()
            -- TODO
            vim.g.git_messenger_include_diff = "current"
        end
    },
    -- Coding
    {
        'numToStr/Comment.nvim',
        lazy = false,
        config = function()
            require("Comment").setup()
        end
    },
    -- {
    --     "simrat39/symbols-outline.nvim",
    --     config = function()
    --         require("symbols-outline").setup()
    --     end,
    -- },
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("treesitter")
        end
    },
    -- {
    -- "nvim-treesitter/nvim-treesitter-textobjects"
    --     config = function()
    --         require_config("treesittertextobjects")
    --     end,
    -- },
    -- {
    --     "folke/trouble.nvim",
    --     dependencies = "kyazdani42/nvim-web-devicons"
    -- },
    -- {
    --     "RishabhRD/nvim-lsputils",
    --     dependencies = "RishabhRD/popfix"
    -- },
    {
        -- Fuzzy file finder
        "nvim-telescope/telescope.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("telescope")
        end
    },
    -- {
    --     "nvim-telescope/telescope-file-browser.nvim",
    --     dependencies = "kyazdani42/nvim-web-devicons",
    -- },
    -- {
    --     "aaronhallaert/advanced-git-search.nvim",
    --     dependencies = {
    --         -- to show diff splits and open commits in browser
    --         "tpope/vim-fugitive",
    --         -- to open commits in browser with fugitive
    --         "tpope/vim-rhubarb",
    --         -- OPTIONAL: to replace the diff from fugitive with diffview.nvim
    --         -- (fugitive is still needed to open in browser)
    --         -- "sindrets/diffview.nvim",
    --     },
    -- },
    { "mbbill/undotree" }, -- Show a tree of undo history
    -- {
    --     "kyazdani42/nvim-tree.lua",
    --     dependencies = "kyazdani42/nvim-web-devicons",
    --     config = function()
    --         require_config("nvimtree")
    --     end
    -- },
    {
        -- Annotations on closing tag, bracket, parenthesis etc.
        "code-biscuits/nvim-biscuits",
        config = function()
            require_config("biscuits")
        end,
    },
    -- Objects
    {
        -- Add surround object for editing
        "tpope/vim-surround"
    },
    -- {
    --     -- Add more targets for commands
    --     "wellle/targets.vim"
    -- },
    -- Improving functionalities
    -- {
    --     -- Show diff of a recovered or swap file
    --     "chrisbra/Recover.vim"
    -- },
    {
        "numToStr/Navigator.nvim",
        config = function()
            require('Navigator').setup()
            vim.keymap.set({ 'n', 't' }, '<C-h>', '<CMD>NavigatorLeft<CR>')
            vim.keymap.set({ 'n', 't' }, '<C-l>', '<CMD>NavigatorRight<CR>')
            vim.keymap.set({ 'n', 't' }, '<C-k>', '<CMD>NavigatorUp<CR>')
            vim.keymap.set({ 'n', 't' }, '<C-j>', '<CMD>NavigatorDown<CR>')
            -- vim.keymap.set({ 'n', 't' }, '<C-p>', '<CMD>NavigatorPrevious<CR>')
        end
    },
    -- {
    --     -- Tmux splits integration
    --     "christoomey/vim-tmux-navigator"
    -- },
    -- {
    --     "Lilja/zellij.nvim",
    --     config = function()
    --         require('zellij').setup {
    --             vimTmuxNavigatorKeybinds = true, -- Will set keybinds like <C-h> to left
    --         }
    --     end
    -- },
    -- {
    --     -- Split line at cursor
    --     "drzel/vim-split-line"
    -- },
    {
        -- Replace word under cursor
        "wincent/scalpel"
    },
    -- {
    --     -- Swap delimited items
    --     "mizlan/iswap.nvim"
    -- },
    -- {
    --     -- Disable search highlighting on mode change
    --     "romainl/vim-cool"
    -- },
    {
        -- Repeat plugin mappings with .
        "tpope/vim-repeat"
    },
    -- {
    --     -- Add sort motion
    --     "sQVe/sort.nvim"
    -- },
    -- {
    --     -- Adds UNIX commands
    --     "tpope/vim-eunuch"
    -- },
    -- {
    --     -- Highlights undo region
    --     "machakann/vim-highlightedundo"
    -- },
    {
        -- Exchange two objects
        "tommcdo/vim-exchange"
    },
    -- {
    --     -- Reapply previous change to a different object
    --     "tommcdo/vim-nowchangethat"
    -- },
    -- {
    --     -- Restore cursor position when reopening files
    --     "farmergreg/vim-lastplace"
    -- },
    -- {
    --     -- Automatic shebang for new files
    --     "Susensio/magic-bang.nvim"
    -- },
    -- {
    --     -- Copy in OS clipboard in SSH
    --     "ojroques/vim-oscyank"
    -- },
    { "norcalli/nvim-colorizer.lua" },
    -- { "sindrets/diffview.nvim",     dependencies = { "nvim-lua/plenary.nvim" } },
    -- {
    --     "kyazdani42/nvim-web-devicons",
    --     config = function()
    --         require_config("icons")
    --     end
    -- },
    -- {
    --     "rmagatti/goto-preview",
    --     config = function()
    -- require('goto-preview').setup {
    --     width = 120; -- Width of the floating window
    --     height = 15; -- Height of the floating window
    --     default_mappings = true; -- Bind default mappings
    --     debug = false; -- Print debug information
    --     opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
    --     post_open_hook = nil -- A function taking two arguments, a buffer and a window to be ran as a hook.
    -- }
    --     end
    -- },
    -- { "lewis6991/impatient.nvim" },
    {
        "laytan/cloak.nvim",
        config = function() require_config("cloak") end
    },
    -- {
    --     "stevearc/dressing.nvim",
    --     config = function()
    --         require_config("dressing")
    --     end
    -- },
    "Yazeed1s/minimal.nvim",
    {
        "bluz71/vim-moonfly-colors",
        priority = 1000,
        config = function()
            vim.g.moonflyWinSeparator = 2
            vim.g.moonflyCursorColor = true
            vim.g.moonflyItalics = false
            vim.g.moonflyUnderlineMatchParen = true
            -- vim.cmd [[ colorscheme moonfly ]]
        end
    },
    {
        "felipeagc/fleet-theme-nvim",
        config = function()
            vim.cmd [[ colorscheme fleet ]]
        end
    },
    -- {
    --     "nathom/filetype.nvim",
    --     config = function()
    --         require("filetype").setup {
    --             overrides = {
    --                 extensions = {
    --                     tf = "terraform",
    --                     tfvars = "terraform",
    --                     tfstate = "json",
    --                 },
    --             },
    --         }
    --     end,
    -- },
    -- {
    --     "SmiteshP/nvim-navic",
    -- }
}

-- glepnir/mutchar.nvim

require("lazy").setup {
    spec = {
        plugins,
        { import = "plugins.lsp" },
    },
    defaults = {
        lazy = false,
    },
    change_detection = {
        enabled = true,
        notify = true,
    },
    rtp = {
        disabled_plugins = {
            "2html_plugin",
            "getscript",
            "getscriptPlugin",
            "gzip",
            "logiPat",
            "matchit",
            "matchparen",
            "netrw",
            "netrwFileHandlers",
            "netrwPlugin",
            "netrwSettings",
            "rrhelper",
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

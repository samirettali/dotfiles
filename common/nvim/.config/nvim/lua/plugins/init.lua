local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system(
        { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
            lazypath })
end
vim.opt.rtp:prepend(lazypath)

function require_config(name)
    local path = "plugins.configs." .. name
    local result, err = pcall(require, path)

    if not result then
        -- vim.notify("could not load config for " .. name .. "\n" .. err, vim.lsp.log_levels.ERROR)
        print("could not load config for " .. name .. "\n" .. err)
    end
end

local plugins = {
    -- Git
    {
        -- Better commit editing
        "rhysd/committia.vim"
    },
    {
        -- Git wrapper
        "tpope/vim-fugitive"
    },
    {
        "rhysd/git-messenger.vim",
        keys = "<Plug>(git-messenger)",
        config = function()
            -- TODO
            vim.g.git_messenger_include_diff = "current"
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        -- Show git diff in the gutter (requires plenary)
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("gitsigns")
        end
    },
    {
        "akinsho/git-conflict.nvim",

        config = function()
            require('git-conflict').setup()
        end
    }, -- Coding
    {
        -- Autopair brackets and other symbols
        "windwp/nvim-autopairs",
        -- after = "nvim-cmp",
        config = function()
            require_config("autopairs")
        end
    },
    {
        "numToStr/Comment.nvim",
        keys = { "gc", "gb" },
        config = function()
            require_config("comment")
        end
    },
    {
        -- Show a panel to browse tags
        "liuchengxu/vista.vim",
        config = function()
            require_config("vista")
        end
    }, -- LSP and related
    {
        "neovim/nvim-lspconfig",

        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("lsp")
        end
    },
    {
        -- Show function signature as you type
        "ray-x/lsp_signature.nvim",
        -- after = "nvim-lspconfig",
        config = function()
            require_config("lspsignature")
        end
    },
    {
        "onsails/lspkind-nvim",
        opt = false,
        config = function()
            require_config("lspkind")
        end
    },
    {
        "glepnir/lspsaga.nvim",

        branch = "main",
        config = function()
            -- require_config("saga")
        end
    },
    {
        "rafamadriz/friendly-snippets",

        module = "cmp_nvim_lsp",
        event = "InsertEnter"
    },
    {
        -- Auto completion
        "hrsh7th/nvim-cmp",
        -- after = "friendly-snippets",
        config = function()
            require_config("cmp")
        end
    }, -- Snippets integration
    {
        "L3MON4D3/LuaSnip",
        dependencies = "friendly-snippets",
        -- after = "nvim-cmp",
        config = function()
            require_config("luasnip")
        end
    },
    {
        "saadparwaiz1/cmp_luasnip",

        -- after = "LuaSnip"
    },
    {
        "hrsh7th/cmp-nvim-lua",

        -- after = "cmp_luasnip"
    },
    {
        "hrsh7th/cmp-nvim-lsp",

        -- after = "cmp-nvim-lua"
    },
    {
        "hrsh7th/cmp-buffer",

        -- after = "cmp-nvim-lsp"
    },
    {
        "hrsh7th/cmp-path",

        -- after = "cmp-buffer"
    },
    {
        "hrsh7th/cmp-cmdline",

        -- after = "nvim-cmp"
    },
    {
        "nvim-treesitter/nvim-treesitter",

        run = ":TSUpdate",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("treesitter")
        end
    }, -- ["nvim-treesitter/nvim-treesitter-textobjects"] = {
    --     config = function()
    --         require_config("treesittertextobjects")
    --     end,
    -- },
    {
        "folke/trouble.nvim",

        dependencies = "kyazdani42/nvim-web-devicons"
    },
    {
        "RishabhRD/nvim-lsputils",

        dependencies = "RishabhRD/popfix"
    }, -- Fuzzy file finder
    {
        "nvim-telescope/telescope.nvim",

        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("telescope")
        end
    },
    {
        -- GPS
        "SmiteshP/nvim-gps",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require_config("gps")
        end
    },
    { "mbbill/undotree" }, -- Show a tree of undo history
    {
        "lukas-reineke/indent-blankline.nvim",

        config = function()
            require_config("indentline")
        end
    },
    {
        "kyazdani42/nvim-tree.lua",

        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require_config("nvimtree")
        end
    },
    {
        "romgrk/barbar.nvim",

        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require_config('barbar')
        end
    },
    {
        "feline-nvim/feline.nvim",
        config = function()
            require_config("feline")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",

        dependencies = {
            'kyazdani42/nvim-web-devicons',
        },
        config = function()
            require_config('lualine')
        end
    },
    {
        "code-biscuits/nvim-biscuits",

        config = function()
            require_config("biscuits")
        end
    }, -- Objects
    { "tpope/vim-surround" }, -- Add surround object for editing
    { "wellle/targets.vim" }, -- Add more targets for commands
    -- Improving functionalities
    { "chrisbra/Recover.vim" }, -- Show diff of a recovered or swap file
    { "junegunn/vim-easy-align" }, -- Align stuff based on a symbol
    { "christoomey/vim-tmux-navigator" }, -- Tmux splits integration
    { "drzel/vim-split-line" }, -- Split line at cursor
    { "wincent/scalpel" }, -- Replace word under cursor
    { "mizlan/iswap.nvim" }, -- Swap delimited items
    { "romainl/vim-cool" }, -- Disable search highlighting on mode change
    { "tpope/vim-repeat" }, -- Repeat plugin mappings with .
    -- ["christoomey/vim-sort-motion"] = {},          -- Add sort motion
    { "tpope/vim-eunuch" }, -- Adds UNIX commands
    { "machakann/vim-highlightedundo" }, -- Highlights undo region
    { "tommcdo/vim-exchange" }, -- Exchange two objects
    { "tommcdo/vim-nowchangethat" }, -- Reapply previous change to a different object
    { "farmergreg/vim-lastplace" }, -- Restore cursor position when reopening files
    { "samirettali/shebang.nvim" }, -- Automatic shebang for new files
    { "ojroques/vim-oscyank" }, -- Copy in OS clipboard in SSH
    {
        "RaafatTurki/hex.nvim",

        config = function()
            require("hex").setup()
        end
    },
    -- {
    --     "rmagatti/auto-session"
    --     config = function()
    --         require_config("autosession")
    --     end,
    -- }, -- Continuously save session
    -- Theme stuff
    { "bluz71/vim-moonfly-colors" },
    { "Yazeed1s/oh-lucy.nvim" },
    { "Mofiqul/vscode.nvim" },
    { "norcalli/nvim-colorizer.lua" },
    {
        "kyazdani42/nvim-web-devicons",

        config = function()
            require_config("icons")
        end
    },
    {
        "rmagatti/goto-preview",

        config = function()
            require_config("goto-preview")
        end
    },
    { "lewis6991/impatient.nvim" }
}

-- glepnir/mutchar.nvim

require("lazy").setup(plugins)

-- merge user plugin table & default plugin table
plugins = require("core.utils").remove_default_plugins(plugins)
plugins = require("core.utils").plugin_list(plugins)

-- return packer.startup(function(use)
--     for _, v in pairs(plugins) do
--         -- TODO test return value
--         use(v)
--     end
--
--     if bootstrap then
--         packer.sync()
--     end
-- end)

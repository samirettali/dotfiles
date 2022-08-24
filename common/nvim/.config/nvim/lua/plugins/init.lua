local bootstrap = false

local packer_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        packer_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
    bootstrap = true
end

local packer = require("packer")

function require_config(name)
    local path = "plugins.configs." .. name
    local result, err = pcall(require, path)

    if not result then
        vim.notify("could not load config for " .. name .. "\n" .. err, vim.lsp.log_levels.ERROR)
    end
end

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
        prompt_border = "single",
    },
    git = {
        clone_timeout = 30,
    },
    auto_clean = false,
    compile_on_sync = true,
    auto_reload_compiled = true,
    autoremove = false,
}

local plugins = {
    ["wbthomason/packer.nvim"] = {
        event = "VimEnter",
        opt = false
    },

    -- Utils
    ["nvim-lua/plenary.nvim"] = {},

    -- Git
    ["rhysd/committia.vim"] = {}, -- Better commit editing
    ["tpope/vim-fugitive"] = {}, -- Git wrapper
    -- ["f-person/git-blame.nvim"] = { -- Show git blame
    --     config = function()
    --         require("plugins.configs.gitblame")
    --     end,
    -- },
    ["rhysd/git-messenger.vim"] = {
        keys = "<Plug>(git-messenger)",
        config = function()
            -- TODO
            vim.g.git_messenger_include_diff = "current"
        end,
    },
    ["lewis6991/gitsigns.nvim"] = { -- Show git diff in the gutter (requires plenary)
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require_config("gitsigns")
        end,
    },
    ["akinsho/git-conflict.nvim"] = {
        config = function()
            require('git-conflict').setup()
        end,
    },
    ["glepnir/mcc.nvim"] = {
        config = function()
            require_config("mcc")
        end
    },
    -- Coding
    ["windwp/nvim-autopairs"] = { -- Autopair brackets and other symbols
        after = "nvim-cmp",
        config = function()
            require_config("autopairs")
        end,
    },

    ["numToStr/Comment.nvim"] = {
        keys = { "gc", "gb" },
        config = function()
            require_config("comment")
        end,
    },

    ["JoosepAlviste/nvim-ts-context-commentstring"] = {},
    ["liuchengxu/vista.vim"] = { -- Show a panel to browse tags
        config = function()
            require_config("vista")
        end,
    },
    ["alvan/vim-closetag"] = {}, -- Automatically close HTML tag
    ["iamcco/markdown-preview.nvim"] = {
        run = "cd app && yarn install",
    },
    ["omnisharp/omnisharp-vim"] = {},

    -- Syntax highlighting
    ["pantharshit00/vim-prisma"] = {},
    ["plasticboy/vim-markdown"] = {},
    ["jparise/vim-graphql"] = {},
    ["dart-lang/dart-vim-plugin"] = {},
    ["TovarishFin/vim-solidity"] = {},

    -- LSP and related
    ["neovim/nvim-lspconfig"] = { -- LSP
        config = function()
            require_config("lsp")
        end,
    },

    ["ray-x/lsp_signature.nvim"] = {
        after = "nvim-lspconfig",
        config = function()
            require_config("lspsignature")
        end,
    },


    ["jose-elias-alvarez/null-ls.nvim"] = {},

    ["onsails/lspkind-nvim"] = {
        opt = false,
        config = function()
            require_config("lspkind")
        end,
    },

    ["glepnir/lspsaga.nvim"] = {
        branch = "main",
        config = function()
            -- require_config("saga")
        end
    },

    ["rafamadriz/friendly-snippets"] = {
        module = "cmp_nvim_lsp",
        event = "InsertEnter",
    },

    ["hrsh7th/nvim-cmp"] = { -- Auto completion
        after = "friendly-snippets",
        config = function()
            require_config("cmp")
        end,
    },

    -- Snippets integration
    ["L3MON4D3/LuaSnip"] = {
        requires = "friendly-snippets",
        after = "nvim-cmp",
        config = function()
            require_config("luasnip")
        end,
    },

    ["saadparwaiz1/cmp_luasnip"] = {
        after = "LuaSnip",
    },

    ["hrsh7th/cmp-nvim-lua"] = {
        after = "cmp_luasnip",
    },

    ["hrsh7th/cmp-nvim-lsp"] = {
        after = "cmp-nvim-lua",
    },

    ["hrsh7th/cmp-buffer"] = {
        after = "cmp-nvim-lsp",
    },

    ["hrsh7th/cmp-path"] = {
        after = "cmp-buffer",
    },
    ["hrsh7th/cmp-cmdline"] = {
        after = "nvim-cmp",
    },

    ["kristijanhusak/vim-dadbod-completion"] = {},

    ["nvim-treesitter/nvim-treesitter"] = {
        run = ":TSUpdate",
        config = function()
            require_config("treesitter")
        end,
    },

    -- ["nvim-treesitter/nvim-treesitter-textobjects"] = {
    --     config = function()
    --         require_config("treesittertextobjects")
    --     end,
    -- },

    ["nvim-treesitter/playground"] = {},
    ["folke/trouble.nvim"] = {
        requires = "kyazdani42/nvim-web-devicons",
    },

    ["RishabhRD/popfix"] = {},
    ["RishabhRD/nvim-lsputils"] = {},

    -- Fuzzy file finder
    ["nvim-telescope/telescope.nvim"] = {
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require_config("telescope")
        end,
    },

    ["nvim-telescope/telescope-file-browser.nvim"] = {
        -- after = "telescope",
        -- config = function()
        --     require("telescope").load_extension "file_browser"
        -- end,
    },

    -- UI components
    ["nanozuki/tabby.nvim"] = {
        config = function()
            require_config("tabby")
        end
    },
    ["SmiteshP/nvim-gps"] = { -- GPS
        requires = "nvim-treesitter/nvim-treesitter",
        config = function()
            require_config("gps")
        end,
    },
    -- ["nvim-lualine/lualine.nvim"] = { -- Status line
    --     after = "nvim-gps",
    --     config = function()
    --         require_config("lualine")
    --     end,
    -- },
    ["j-hui/fidget.nvim"] = {
        config = function()
            require("fidget").setup()
        end
    },
    ["stevearc/dressing.nvim"] = {
        config = function()
            require_config("dressing")
        end,
    },
    ["feline-nvim/feline.nvim"] = {
        config = function()
            require_config("feline")
        end,
    },
    ["MunifTanjim/nui.nvim"] = {},
    ["mbbill/undotree"] = {}, -- Show a tree of undo history
    ["lukas-reineke/indent-blankline.nvim"] = {
        config = function()
            require_config("indentline")
        end,
    },
    ["simrat39/symbols-outline.nvim"] = {},
    ["kyazdani42/nvim-tree.lua"] = {
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require_config("nvimtree")
        end,
    },

    ["code-biscuits/nvim-biscuits"] = {
        config = function()
            require_config("biscuits")
        end,
    },

    ["rcarriga/nvim-notify"] = {
        config = function()
        end,
    },

    -- Objects
    ["tpope/vim-surround"] = {}, -- Add surround object for editing
    ["wellle/targets.vim"] = {}, -- Add more targets for commands

    -- Improving functionalities
    ["chrisbra/Recover.vim"] = {}, -- Show diff of a recovered or swap file
    ["junegunn/vim-easy-align"] = {}, -- Align stuff based on a symbol
    ["christoomey/vim-tmux-navigator"] = {}, -- Tmux splits integration
    ["drzel/vim-split-line"] = {}, -- Split line at cursor
    ["wincent/scalpel"] = {}, -- Replace word under cursor
    ["mizlan/iswap.nvim"] = {}, -- Swap delimited items
    ["romainl/vim-cool"] = {}, -- Disable search highlighting on mode change
    ["tpope/vim-repeat"] = {}, -- Repeat plugin mappings with .
    -- ["christoomey/vim-sort-motion"] = {},          -- Add sort motion
    ["tpope/vim-eunuch"] = {}, -- Adds UNIX commands
    ["machakann/vim-highlightedundo"] = {}, -- Highlights undo region
    ["tommcdo/vim-exchange"] = {}, -- Exchange two objects
    ["tommcdo/vim-nowchangethat"] = {}, -- Reapply previous change to a different object
    ["farmergreg/vim-lastplace"] = {}, -- Restore cursor position when reopening files
    ["samirettali/shebang.nvim"] = {}, -- Automatic shebang for new files
    ["ojroques/vim-oscyank"] = {}, -- Copy in OS clipboard in SSH
    ["phaazon/hop.nvim"] = {
        branch = "v2", -- optional but strongly recommended
        config = function()
            require_config("hop")
        end
    },

    -- ["rmagatti/auto-session"] = {
    --     config = function()
    --         require("plugins.configs.autosession")
    --     end,
    -- }, -- Continuously save session

    -- Colorscheme
    ["bluz71/vim-moonfly-colors"] = {},
    ["NvChad/base46"] = {
        after = "plenary.nvim",
        -- config = function()
        --    local ok, base46 = pcall(require, "base46")
        --
        --    if ok then
        --       base46.load_theme()
        --    end
        -- end,
    },
    ["catppuccin/nvim"] = {
        as = "catppuccin",
        config = function()
            require_config("catppuccin")
        end,
    },
    ["norcalli/nvim-colorizer.lua"] = {},
    ["kyazdani42/nvim-web-devicons"] = {
        config = function()
            require_config("icons")
        end,
    },

    -- Debugging
    -- ["mfussenegger/nvim-dap"] = {
    --     config = function()
    --         require("plugins.configs.dap")
    --     end,
    -- },
    -- ["theHamsta/nvim-dap-virtual-text"] = {}
    -- ["rcarriga/nvim-dap-ui"] = {
    --   requires = "mfussenegger/nvim-dap",
    -- }

    -- Other
    ["nvim-telescope/telescope-symbols.nvim"] = {},
    -- ["github/copilot.vim"] = {},
    ["rmagatti/goto-preview"] = {
        config = function()
            require_config("goto-preview")
        end,
    },
    ["lewis6991/impatient.nvim"] = {},
    ["nanotee/sqls.nvim"] = {
    },
    -- ["lcheylus/overlength.nvim"] = {
    --     config = function()
    --         require('overlength').setup({
    --             -- Overlength highlighting enabled by default
    --             enabled = true,

    --             -- Colors for highlight by specifying a ctermbg and bg
    --             ctermbg = 'darkgrey',
    --             bg = '#8B0000',

    --             -- Mode to use textwidth local options
    --             -- 0: Don't use textwidth at all, always use config.default_overlength.
    --             -- 1: Use `textwidth, unless it's 0, then use config.default_overlength.
    --             -- 2: Always use textwidth. There will be no highlighting where
    --             --    textwidth == 0, unless added explicitly
    --             textwidth_mode = 2,
    --             -- Default overlength with no filetype
    --             default_overlength = 80,
    --             -- How many spaces past your overlength to start highlighting
    --             grace_length = 1,
    --             -- Highlight only the column or until the end of the line
    --             highlight_to_eol = true,

    --             -- List of filetypes to disable overlength highlighting
    --             disable_ft = { 'qf', 'help', 'man', 'packer', 'NvimTree', 'Telescope', 'WhichKey' },
    --         })
    --     end
    -- }
    --
    -- ["ggandor/leap.nvim"] = {
    --     requires = "tpope/vim-repeat",
    --     config = function()
    --         require('leap').set_default_keymaps()
    --     end
    -- }
}

-- merge user plugin table & default plugin table
plugins = require("core.utils").remove_default_plugins(plugins)
plugins = require("core.utils").plugin_list(plugins)

return packer.startup(function(use)
    for _, v in pairs(plugins) do
        -- TODO test return value
        use(v)
    end

    if bootstrap then
        packer.sync()
    end
end)

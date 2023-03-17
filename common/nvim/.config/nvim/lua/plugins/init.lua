local function require_config(name)
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
            require("git-conflict").setup({})
        end
    },
    -- Coding
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
        "VidocqH/lsp-lens.nvim",
        config = function()
            require 'lsp-lens'.setup({
                enable = true,
                include_declaration = false, -- Reference include declaration
                sections = { -- Enable / Disable specific request
                    definition = false,
                    references = true,
                    implementation = true,
                },
            })
        end,
    },
    {
        "ErichDonGubler/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()
        end,
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
    },
    {
        "hrsh7th/cmp-nvim-lua",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "hrsh7th/cmp-buffer",
    },
    {
        "hrsh7th/cmp-path",
    },
    {
        "hrsh7th/cmp-cmdline",
    },
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
    {
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons"
    },
    {
        "RishabhRD/nvim-lsputils",
        dependencies = "RishabhRD/popfix"
    },
    {
        -- Fuzzy file finder
        "nvim-telescope/telescope.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require_config("telescope")
        end
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
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
        "freddiehaddad/feline.nvim",
        config = function()
            require_config("feline")
        end
    },
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
    {
        -- Add more targets for commands
        "wellle/targets.vim"
    },
    -- Improving functionalities
    {
        -- Show diff of a recovered or swap file
        "chrisbra/Recover.vim"
    },
    {
        -- Align stuff based on a symbol
        "junegunn/vim-easy-align"
    },
    {
        -- Tmux splits integration
        "christoomey/vim-tmux-navigator"
    },
    {
        -- Split line at cursor
        "drzel/vim-split-line"
    },
    {
        -- Replace word under cursor
        "wincent/scalpel"
    },
    {
        -- Swap delimited items
        "mizlan/iswap.nvim"
    },
    {
        -- Disable search highlighting on mode change
        "romainl/vim-cool"
    },
    {
        -- Repeat plugin mappings with .
        "tpope/vim-repeat"
    },
    {
        -- Add sort motion
        "sQVe/sort.nvim"
    },
    {
        -- Adds UNIX commands
        "tpope/vim-eunuch"
    },
    {
        -- Highlights undo region
        "machakann/vim-highlightedundo"
    },
    {
        -- Exchange two objects
        "tommcdo/vim-exchange"
    },
    {
        -- Reapply previous change to a different object
        "tommcdo/vim-nowchangethat"
    },
    {
        -- Restore cursor position when reopening files
        "farmergreg/vim-lastplace"
    },
    {
        -- Automatic shebang for new files
        "samirettali/shebang.nvim"
    },
    {
        -- Copy in OS clipboard in SSH
        "ojroques/vim-oscyank"
    },
    {
        -- Hex editing
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
    -- },
    {
        "bluz71/vim-moonfly-colors",
        config = function()
            vim.cmd [[ colorscheme moonfly ]]
        end
    },
    {
        "olimorris/onedarkpro.nvim",
    },
    { "Mofiqul/vscode.nvim" },
    {
        "AlexvZyl/nordic.nvim",
        config = function()
            -- require_config("nordic")
        end,
    },
    { "norcalli/nvim-colorizer.lua" },
    { "sindrets/diffview.nvim",     dependencies = { "nvim-lua/plenary.nvim" } },
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
    { "lewis6991/impatient.nvim" },
    {
        "Tummetott/reticle.nvim",
        config = function()
            require('reticle').setup {
                -- add options here if you want to overwrite defaults
            }
        end
    },
    {
        "mfussenegger/nvim-dap",
        config = function()
            require_config("dap")
        end
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = "mfussenegger/nvim-dap"
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = "mfussenegger/nvim-dap",
        config = function()
            require_config("dapui")
        end
    },
    {
        "luukvbaal/statuscol.nvim",
        config = function() require("statuscol").setup() end
    },
    {
        "Eandrju/cellular-automaton.nvim"
    },
    {
        "laytan/cloak.nvim",
        config = function() require_config("cloak") end
    },
    {
        "hashicorp/terraform-ls"
    }
}

-- glepnir/mutchar.nvim

local opts = {
    defaults = {
        lazy = false,
    },
    change_detection = {
        enabled = true,
        notify = true,
    }
}

require("lazy").setup(plugins, opts)

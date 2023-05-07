local utils = require("core.utils")

local function require_config(name)
    local path = "plugins.configs." .. name
    local result, err = pcall(require, path)

    if not result then
        vim.notify("could not load config for " .. name .. "\n" .. err, vim.lsp.log_levels.ERROR)
    end
end

-- local function setup_plugin(name)
--     return function()
--         local present, plugin = pcall(require, name)
--         if not present then
--             return false
--         end
--
--         if plugin["setup"] ~= nil then
--             plugin.setup {}
--         elseif plugin["init"] ~= nil then
--             plugin.init {}
--         else
--             return false
--         end
--
--         return true
--     end
-- end

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
    -- {
    --     "akinsho/git-conflict.nvim",
    --     config = function()
    --         require("git-conflict").setup({})
    --     end
    -- },
    {
        "f-person/git-blame.nvim",
        config = function()
            require_config("gitblame")
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
        "simrat39/symbols-outline.nvim",
        config = function()
            require("symbols-outline").setup()
        end,
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
        config = function() require_config("lspsignature") end,
    },
    {
        "onsails/lspkind-nvim",
        opt = false,
        config = function() require_config("lspkind") end,
    },
    {
        "Fildo7525/pretty_hover",
        config = function() require_config('prettyhover') end,
    },
    -- {
    --     "glepnir/lspsaga.nvim",

    --     branch = "main",
    --     config = function()
    --         -- require_config("saga")
    --     end
    -- },
    -- {
    --     "VidocqH/lsp-lens.nvim",
    --     config = function()
    --         require 'lsp-lens'.setup({
    --             enable = true,
    --             include_declaration = false, -- Reference include declaration
    --             sections = {
    --                 -- Enable / Disable specific request
    --                 definition = false,
    --                 references = true,
    --                 implementation = true,
    --             },
    --         })
    --     end,
    -- },
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
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        config = function()
            require_config("navic")
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
        "nvim-lualine/lualine.nvim",
        config = function()
            require_config("lualine")
        end,
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
            -- vim.cmd [[ colorscheme moonfly ]]
        end
    },
    {
        "Yazeed1s/minimal.nvim",
        config = function()
            vim.cmd [[ colorscheme minimal ]]
        end,
    },
    {
        "Yazeed1s/oh-lucy.nvim"
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
    -- {
    --     "rcarriga/nvim-notify",
    --     config = function()
    --         vim.notify = require("notify")
    --     end,
    -- },
    {
        "Eandrju/cellular-automaton.nvim"
    },
    {
        "laytan/cloak.nvim",
        config = function() require_config("cloak") end
    },
    {
        "hashicorp/terraform-ls"
    },
    {
        "stevearc/dressing.nvim",
        config = function()
            require_config("dressing")
        end
    },
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup {
                log_level = "error",
                auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            }
        end
    },
    {
        "kdheepak/lazygit.nvim",
        config = function()
            vim.keymap.set("n", "<Leader>gg", ":LazyGit<CR>")
        end
    },
    -- {
    --     "chrisgrieser/nvim-spider",
    --     lazy = false,
    --     config = function()
    --         -- Keymaps
    --         vim.keymap.set({ "n", "o", "x" }, "w", function() require("spider").motion("w") end, { desc = "Spider-w" })
    --         vim.keymap.set({ "n", "o", "x" }, "e", function() require("spider").motion("e") end, { desc = "Spider-e" })
    --         vim.keymap.set({ "n", "o", "x" }, "b", function() require("spider").motion("b") end, { desc = "Spider-b" })
    --         vim.keymap.set({ "n", "o", "x" }, "ge", function() require("spider").motion("ge") end, { desc = "Spider-ge" })
    --     end,
    -- },
    {
        "stevearc/overseer.nvim",
        config = function()
            require('overseer').setup()
        end
    },
    {
        "nanotee/sqls.nvim"
    },
    {
        "toppair/peek.nvim",
        build = 'deno task --quiet build:fast',
        config = function()
            -- default config:
            require('peek').setup({
                auto_load = true,        -- whether to automatically load preview when
                -- entering another markdown buffer
                close_on_bdelete = true, -- close preview window on buffer delete
                syntax = true,           -- enable syntax highlighting, affects performance
                theme = 'dark',          -- 'dark' or 'light'
                update_on_change = true,
                app = 'webview',         -- 'webview', 'browser', string or a table of strings
                -- explained below

                filetype = { 'markdown' }, -- list of filetypes to recognize as markdown
                -- relevant if update_on_change is true
                throttle_at = 200000,      -- start throttling when file exceeds this
                -- amount of bytes in size
                throttle_time = 'auto',    -- minimum amount of time in milliseconds
                -- that has to pass before starting new render
            })
        end,
    },
    -- {
    --     "projekt0n/circles.nvim",
    --     config = function()
    --         require("circles").setup()
    --     end,
    -- },
}

-- glepnir/mutchar.nvim

-- require("lazy").setup(plugins, opts)
require("lazy").setup {
    spec = {
        plugins,
        { import = "plugins.ui" },
        { import = "plugins.extras.pde" },
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
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
    },
}

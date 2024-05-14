return {
    "tpope/vim-repeat",                           -- Repeat plugin mappings with .
    "tommcdo/vim-exchange",                       -- Exchange two objects
    "sindrets/diffview.nvim",                     -- Improve diff view
    -- "tpope/vim-eunuch",                           -- UNIX commands inside neovim, disabled because it broke something
    "rhysd/committia.vim",                        -- Better commit editing
    "tpope/vim-surround",                         -- Add surround object for editing
    "github/copilot.vim",                         -- Copilot
    "SmiteshP/nvim-navic",                        -- LSP breadcrumbs
    { "stevearc/dressing.nvim",  config = true }, -- Floating UI selectors
    { "j-hui/fidget.nvim",       config = true }, -- Show LSP loading status
    { "stevearc/oil.nvim",       config = true }, -- File explorer
    { "laytan/cloak.nvim",       config = true }, -- Hide secrets in .env files
    { "lewis6991/gitsigns.nvim", config = true }, -- Git signs integration
    -- { "numToStr/Comment.nvim",   config = true }, -- Comment toggler
    {
        "David-Kunz/gen.nvim", -- Access LLMs with Ollama
        opts = {
            show_prompt = true,
            model = "deepseek-coder:7b-instruct",
            display_mode = "split",
            command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
        }
    },
    {
        "folke/persistence.nvim", -- Session manager
        opts = {},
        event = "BufReadPre",
        keys = {
            { "<leader>s", [[<cmd>lua require("persistence").load()<cr>]] },
        }
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
    },
    {
        "Wansmer/treesj",
        keys = { '<space>m', '<space>j', '<space>s' },
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require('treesj').setup()
        end,
    },
    {
        -- Autopair brackets and other symbols
        "windwp/nvim-autopairs",
        dependencies = "hrsh7th/nvim-cmp",
        config = function()
            local autopairs = require("nvim-autopairs")
            local cmp = require("cmp")

            autopairs.setup {
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            }

            local cmp_autopairs = require "nvim-autopairs.completion.cmp"

            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    },
    {
        "AlexvZyl/nordic.nvim",
        config = function()
            require("nordic").load()
        end
    },
    { "deparr/tairiki.nvim" }
}

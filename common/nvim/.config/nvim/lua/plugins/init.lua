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
        "aaronhallaert/advanced-git-search.nvim",
        dependencies = {
            -- to show diff splits and open commits in browser
            "tpope/vim-fugitive",
            -- to open commits in browser with fugitive
            "tpope/vim-rhubarb",
            -- OPTIONAL: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            -- "sindrets/diffview.nvim",
        },
    },
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
        "Susensio/magic-bang.nvim"
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
    {
        "projekt0n/circles.nvim",
        config = function()
            require("circles").setup()
        end,
    },
    {
        "nathom/filetype.nvim",
        config = function()
            require("filetype").setup {
                overrides = {
                    extensions = {
                        tf = "terraform",
                        tfvars = "terraform",
                        tfstate = "json",
                    },
                },
            }
        end,
    },
    {
        "SmiteshP/nvim-navic",
        config = function()
        end,
    }
}

-- glepnir/mutchar.nvim

require("lazy").setup {
    spec = {
        plugins,
        { import = "plugins.ui" },
        { import = "plugins.lsp" },
        { import = "plugins.extras.pde" },
        { import = "plugins.dap" },
        { import = "plugins.themes" },
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

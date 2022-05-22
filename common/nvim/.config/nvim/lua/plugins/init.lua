local plugin_settings = require("core.utils").load_config().plugins
-- local present, packer = pcall(require, "plugins.packerInit")


local present, packer = pcall(require, "packer")
local bootstrap = false

if not present then
   local packer_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"

   print "Cloning packer.."
   -- remove the dir before cloning
   vim.fn.delete(packer_path, "rf")
   vim.fn.system {
      "git",
      "clone",
      "https://github.com/wbthomason/packer.nvim",
      "--depth",
      "20",
      packer_path,
   }

   vim.cmd "packadd packer.nvim"
   present, packer = pcall(require, "packer")

   if present then
      print "Packer cloned successfully."
        bootstrap = true
   else
      error("Couldn't clone packer !\nPacker path: " .. packer_path .. "\n" .. packer)
   end
end

packer.init {
   display = {
      open_fn = function()
         return require("packer.util").float { border = "single" }
      end,
      prompt_border = "single",
   },
   git = {
      clone_timeout = 30, -- seconds
   },
   auto_clean = false,
   compile_on_sync = true,
   auto_reload_compiled = false, -- Automatically reload the compiled file after creating it.
   autoremove = false,
}

-- if not present then
--    return false
-- end
--
local plugins = {
  ["wbthomason/packer.nvim"] = {
      event = "VimEnter",
      opt = false
  },

  ["nvim-lua/plenary.nvim"] = {},

  -- Git
  ["rhysd/committia.vim"] = {},                  -- Better commit editing
  ["tpope/vim-fugitive"] = {},                   -- Git wrapper
  ["f-person/git-blame.nvim"] = {
      config = function()
          require("plugins.configs.gitblame")
      end

  },              -- Show git blame
  ["lewis6991/gitsigns.nvim"] = {                -- Show git diff in the gutter (requires plenary)
      requires = "nvim-lua/plenary.nvim",
      config = function()
          require("plugins.configs.gitsigns")
      end,
  },

  -- Coding
  ["windwp/nvim-autopairs"] = {                  -- Autopair brackets and other symbols
      after = "nvim-cmp",
      config = function()
          require("plugins.configs.autopairs")
      end,
  },

   ["numToStr/Comment.nvim"] = {
      module = "Comment",
      keys = { "gc", "gb" },
      config = function()
         require("plugins.configs.comment")
      end,
   },

  ["JoosepAlviste/nvim-ts-context-commentstring"] = {},
  ["liuchengxu/vista.vim"] = {                   -- Show a panel to browse tags
    config = function()
        require("plugins.configs.vista")
    end,
  },
  ["alvan/vim-closetag"] = {},                   -- Automatically close HTML tag
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
  ["neovim/nvim-lspconfig"] = {                -- LSP
      module = "lspconfig",
      config = function()
          require("plugins.configs.lsp")
      end,
  },

  ["ray-x/lsp_signature.nvim"] = {
      after = "nvim-lspconfig",
      config = function()
         require("plugins.configs.lspsignature")
      end,
   },


  ["jose-elias-alvarez/null-ls.nvim"] = {},

  ["onsails/lspkind-nvim"] = {
      opt = false,
      config = function()
          require("plugins.configs.lspkind")
      end,
  },

  ["rafamadriz/friendly-snippets"] = {
      module = "cmp_nvim_lsp",
      event = "InsertEnter",
  },

  ["hrsh7th/nvim-cmp"] = {                     -- Auto completion
      after = "friendly-snippets",
      config = function()
          require("plugins.configs.cmp")
      end,
  },

  -- Snippets integration
  ["L3MON4D3/LuaSnip"] = {
    requires = "friendly-snippets",
    after = "nvim-cmp",
    config = function()
        require("plugins.configs.luasnip")
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

   ["kristijanhusak/vim-dadbod-completion"] = {},

  ["nvim-treesitter/nvim-treesitter"] = {
      run = ":TSUpdate",
      config = function()
          require("plugins.configs.treesitter")
      end,
  },

  ["nvim-treesitter/nvim-treesitter-textobjects"] = {
      config = function()
          require("plugins.configs.treesittertextobject")
      end,
  },

  ["nvim-treesitter/playground"] = {},
  ["folke/trouble.nvim"] = {
       requires = "kyazdani42/nvim-web-devicons",
  },

  ["RishabhRD/popfix"] = {},
  ["RishabhRD/nvim-lsputils"] = {},

  -- Fuzzy file finder
  ["nvim-telescope/telescope.nvim"] = {
    cmd = "Telescope",
    config = function()
        require("plugins.configs.telescope")
    end,
    requires = {{
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
    }},
  },

  -- UI components
  ["noib3/nvim-cokeline"] = {
      requires = "kyazdani42/nvim-web-devicons", -- If you want devicons
      config = function()
          require("plugins.configs.cokeline")
      end,
  },
  ["nvim-lualine/lualine.nvim"] = {                 -- Status line
    config = function()
        require("plugins.configs.lualine")
    end,
  },
  -- ["famiu/feline.nvim"] = {                 -- Status line
  --   after = "nvim-web-devicons",
  --   config = function()
  --       require("plugins.configs.feline")
  --   end,
  -- },
  ["SmiteshP/nvim-gps"] = {                 -- GPS
    requires = "nvim-treesitter/nvim-treesitter"
  },
  ["MunifTanjim/nui.nvim"] = {},
  ["mbbill/undotree"] = {},                      -- Show a tree of undo history
  ["lukas-reineke/indent-blankline.nvim"] = {
      config = function()
          require("plugins.configs.indentline")
      end,
  },
  ["simrat39/symbols-outline.nvim"] = {},
  ["kyazdani42/nvim-tree.lua"] = {
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
        require("plugins.configs.nvimtree")
    end,
  },
  -- Objects
  ["tpope/vim-surround"] = {},                   -- Add surround object for editing
  ["wellle/targets.vim"] = {},                   -- Add more targets for commands

  -- Improving functionalities
  ["chrisbra/Recover.vim"] = {},                 -- Show diff of a recovered or swap file
  ["junegunn/vim-easy-align"] = {},              -- Align stuff based on a symbol
  ["christoomey/vim-tmux-navigator"] = {},       -- Tmux splits integration
  ["drzel/vim-split-line"] = {},                 -- Split line at cursor
  ["wincent/scalpel"] = {},                      -- Replace word under cursor
  ["machakann/vim-swap"] = {},                   -- Swap delimited items
  ["romainl/vim-cool"] = {},                     -- Disable search highlighting on mode change
  ["tpope/vim-repeat"] = {},                     -- Repeat plugin mappings with .
  -- ["christoomey/vim-sort-motion"] = {},          -- Add sort motion
  ["tpope/vim-eunuch"] = {},                     -- Adds UNIX commands
  ["machakann/vim-highlightedundo"] = {},        -- Highlights undo region
  ["tommcdo/vim-exchange"] = {},                 -- Exchange two objects
  ["tommcdo/vim-nowchangethat"] = {},            -- Reapply previous change to a different object
  ["farmergreg/vim-lastplace"] = {},             -- Restore cursor position when reopening files
  ["samirettali/shebang.nvim"] = {},             -- Automatic shebang for new files
  ["ojroques/vim-oscyank"] = {},                 -- Copy in OS clipboard in SSH
  -- ["rmagatti/auto-session"] = {},             -- Continuously save session

  -- Colorscheme
  ["bluz71/vim-moonfly-colors"] = {},
  ["kyazdani42/nvim-web-devicons"] = {
        config = function()
            require("plugins.configs.icons")
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
  ["github/copilot.vim"] = {},
  ["rmagatti/goto-preview"] = {
      config = function()
          require("plugins.configs.goto-preview")
      end,
  },
  ["lewis6991/impatient.nvim"] = {},
}

-- merge user plugin table & default plugin table
plugins = require("core.utils").remove_default_plugins(plugins)
plugins = require("core.utils").plugin_list(plugins)

return packer.startup(function(use)
    for _, v in pairs(plugins) do
        use(v)
    end

    if bootstrap then
        packer.sync()
    end
end)

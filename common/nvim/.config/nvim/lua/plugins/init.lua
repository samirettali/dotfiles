local plugin_settings = require("core.utils").load_config().plugins
local present, packer = pcall(require, plugin_settings.options.packer.init_file)

if not present then
   return false
end

local plugins = {
  ['nvim-lua/plenary.nvim'] = {},
  ['wbthomason/packer.nvim'] = {
      opt = true
  },

  -- Git
  ['rhysd/committia.vim'] = {},                  -- Better commit editing
  ['tpope/vim-fugitive'] = {},                   -- Git wrapper
  ['f-person/git-blame.nvim'] = {},              -- Show git blame
  ['lewis6991/gitsigns.nvim'] = {},              -- Show git diff in the gutter (requires plenary)
    requires = {{
      'nvim-lua/plenary.nvim'
    }}
  },

  -- Coding
  ['windwp/nvim-autopairs'] = {},                -- Autopair brackets and other symbols
  ['terrortylor/nvim-comment'] = {},             -- Commenting plugin
  ['JoosepAlviste/nvim-ts-context-commentstring'] = {},
  ['liuchengxu/vista.vim'] = {},                 -- Show a panel to browse tags
  ['alvan/vim-closetag'] = {},                   -- Automatically close HTML tag
  ['iamcco/markdown-preview.nvim'], = {
      run = 'cd app && yarn install',
  },
  ['omnisharp/omnisharp-vim'] = {},

  -- Syntax highlighting
  ['pantharshit00/vim-prisma'] = {},
  ['plasticboy/vim-markdown'] = {},
  ['jparise/vim-graphql'] = {},
  ['dart-lang/dart-vim-plugin'] = {},
  ['TovarishFin/vim-solidity'] = {},

  -- LSP and related
  ['neovim/nvim-lspconfig'] = {},                -- LSP
  ['jose-elias-alvarez/null-ls.nvim'] = {},

  ['hrsh7th/nvim-cmp'] = {},                     -- Auto completion
  ['hrsh7th/cmp-nvim-lsp'] = {},
  ['hrsh7th/cmp-buffer'] = {},
  ['hrsh7th/cmp-path'] = {},
  ['hrsh7th/cmp-cmdline'] = {},
  ['hrsh7th/cmp-vsnip'] = {},

  ['nvim-treesitter/nvim-treesitter'] = {
      run = ':TSUpdate',
  },

  ['nvim-treesitter/playground'] = {},
  ['onsails/lspkind-nvim'] = {},
  ['folke/trouble.nvim'] = {
       requires = "kyazdani42/nvim-web-devicons",
       config = function()
           require("trouble").setup{}
       end
  }

  ['RishabhRD/popfix'] = {},
  ['RishabhRD/nvim-lsputils'] = {},

  -- Snippets integration
  ['hrsh7th/vim-vsnip'] = {},
  ['hrsh7th/vim-vsnip-integ'] = {},
  ['craigmac/vim-vsnip-snippets'] = {},

  -- Fuzzy file finder
  ['nvim-telescope/telescope.nvim'] = {
    requires = {{
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    }}
  },
  ['nvim-telescope/telescope-fzy-native.nvim'] = {},

  -- UI components
  ['nanozuki/tabby.nvim'] = {},               -- Buffers bar
  ['famiu/feline.nvim'] = {},                 -- Status line
  ['SmiteshP/nvim-gps'] = {                 -- GPS
    requires = "nvim-treesitter/nvim-treesitter"
  },
  ['MunifTanjim/nui.nvim'] = {},
  ['mbbill/undotree'] = {},                      -- Show a tree of undo history
  ['lukas-reineke/indent-blankline.nvim'] = {},  -- Show indent line
  ['simrat39/symbols-outline.nvim'] = {},
  ['nvim-neo-tree/neo-tree.nvim'] = {
    requires = 'kyazdani42/nvim-web-devicons',
  }

  ['yardnsm/vim-import-cost'] = {
    run = 'yarn install',
  }
  ['sindrets/diffview.nvim'] = {},

  -- Objects
  ['tpope/vim-surround'] = {},                   -- Add surround object for editing
  -- use {'chaoren/vim-wordmotion'}            -- Treat words separated by undescores, case changing etc
  ['wellle/targets.vim'] = {},                   -- Add more targets for commands

  -- Improving functionalities
  ['chrisbra/Recover.vim'] = {},                 -- Show diff of a recovered or swap file
  ['junegunn/vim-easy-align'] = {},              -- Align stuff based on a symbol
  ['christoomey/vim-tmux-navigator'] = {},       -- Tmux splits integration
  ['drzel/vim-split-line'] = {},                 -- Split line at cursor
  ['wincent/scalpel'] = {},                      -- Replace word under cursor
  ['machakann/vim-swap'] = {},                   -- Swap delimited items
  ['romainl/vim-cool'] = {},                     -- Disable search highlighting on mode change
  ['tpope/vim-repeat'] = {},                     -- Repeat plugin mappings with .
  ['norcalli/nvim-colorizer.lua'] = {},          -- Show colors
  ['justinmk/vim-sneak'] = {},                   -- Adds a motion
  ['christoomey/vim-sort-motion'] = {},          -- Add sort motion
  ['tpope/vim-eunuch'] = {},                     -- Adds UNIX commands
  ['machakann/vim-highlightedundo'] = {},        -- Highlights undo region
  ['tommcdo/vim-exchange'] = {},                 -- Exchange two objects
  ['tommcdo/vim-nowchangethat'] = {},            -- Reapply previous change to a different object
  ['farmergreg/vim-lastplace'] = {},             -- Restore cursor position when reopening files
  ['samirettali/shebang.nvim'] = {},             -- Automatic shebang for new files
  ['ojroques/vim-oscyank'] = {},                 -- Copy in OS clipboard in SSH
  ['rmagatti/auto-session'] = {},             -- Continuously save session

  -- Colorscheme
  ['bluz71/vim-moonfly-colors'] = {},
  ['NvChad/base46'] = {},

  -- Debugging
  -- use 'mfussenegger/nvim-dap'
  -- use {'theHamsta/nvim-dap-virtual-text'}
  -- use {'rcarriga/nvim-dap-ui',
    -- requires = {"mfussenegger/nvim-dap"}
  -- }

  -- Other
  ['jez/vim-superman'] = {},                     -- Use vman to read man inside vim
  ['nvim-telescope/telescope-symbols.nvim'] = {},
  ['nvim-treesitter/nvim-treesitter-textobjects'] = {},
  ['github/copilot.vim'] = {},
  ['rmagatti/goto-preview'] = {},
  ['lewis6991/impatient.nvim'] = {}
}


plugins = require("core.utils").remove_default_plugins(plugins)
-- merge user plugin table & default plugin table
plugins = require("core.utils").plugin_list(plugins)

return packer.startup(function(use)
   for _, v in pairs(plugins) do
      use(v)
   end
end)

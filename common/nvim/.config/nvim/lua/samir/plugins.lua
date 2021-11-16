local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
else
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}

  -- Git
  use {'rhysd/committia.vim'}                  -- Better commit editing
  use {'tpope/vim-fugitive'}                   -- Git wrapper
  use {'f-person/git-blame.nvim'}              -- Show git blame
  use {'lewis6991/gitsigns.nvim',              -- Show git diff in the gutter (requires plenary)
    requires = {{
      'nvim-lua/plenary.nvim'
    }}
  }

  -- Coding
  use {'windwp/nvim-autopairs'}                -- Autopair brackets and other symbols
  use {'terrortylor/nvim-comment'}             -- Commenting plugin
  use {'JoosepAlviste/nvim-ts-context-commentstring'}
  use {'liuchengxu/vista.vim'}                 -- Show a panel to browse tags
  use {'alvan/vim-closetag'}                   -- Automatically close HTML tag
  -- use {'AndrewRadev/tagalong.vim'}             -- Automatically rename matching HTML tag
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install'}
  use {'omnisharp/omnisharp-vim'}

  -- Syntax highlighting
  use {'pantharshit00/vim-prisma'}
  use {'plasticboy/vim-markdown'}
  use {'jparise/vim-graphql'}
  use {'dart-lang/dart-vim-plugin'}
  use {'TovarishFin/vim-solidity'}

  -- LSP and related
  use {'neovim/nvim-lspconfig'}                -- LSP
  use {'nvim-lua/lsp_extensions.nvim'}
  use {'jose-elias-alvarez/null-ls.nvim'}

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-vsnip'
  use {'hrsh7th/nvim-cmp'}                     -- Auto completion

  use {'nvim-treesitter/nvim-treesitter',
    branch = '0.5-compat',
    run = ':TSUpdate'
  }
  use {'nvim-treesitter/playground'}
  use {'onsails/lspkind-nvim'}
  use {'folke/trouble.nvim',
       requires = "kyazdani42/nvim-web-devicons",
       config = function() require("trouble").setup {} end
  }

  use 'RishabhRD/popfix'
  use 'RishabhRD/nvim-lsputils'

  -- Snippets integration
  use {'hrsh7th/vim-vsnip'}
  use {'hrsh7th/vim-vsnip-integ'}
  use {'craigmac/vim-vsnip-snippets'}

  -- Fuzzy file finder
  use {'nvim-telescope/telescope.nvim',
    requires = {{
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    }}
  }
  use {'nvim-telescope/telescope-fzy-native.nvim'}

  -- UI components
  use {'romgrk/barbar.nvim'}                -- Buffers bar
  use {'famiu/feline.nvim'}                 -- Status line
  use {'SmiteshP/nvim-gps',
       requires = "nvim-treesitter/nvim-treesitter"
  }
  use {'MunifTanjim/nui.nvim'}
  -- use {'glepnir/galaxyline.nvim'}
  use {'mbbill/undotree'}                      -- Show a tree of undo history
  use {'lukas-reineke/indent-blankline.nvim'}  -- Show indent line
  use {'simrat39/symbols-outline.nvim'}
  --[[ use {
    "projekt0n/circles.nvim",
    requires = {{"kyazdani42/nvim-web-devicons"}, {"kyazdani42/nvim-tree.lua", opt = true}},
    config = function()
      require("circles").setup({
        icons = {
          empty = "",
          filled = "",
          lsp_prefix = ""
        },
        -- override lsp_diagnostic virtual-text icon with `icons.lsp_prefix`
        lsp = true
      })
    end
  } ]]

  use {'kyazdani42/nvim-tree.lua',             -- Tree navigation
    requires = {{
      'kyazdani42/nvim-web-devicons'
    }},
    config = function()
      require('nvim-tree').setup {
        nvim_tree_auto_open = false,
        nvim_tree_auto_close = true,
        nvim_tree_follow = true,
        nvim_tree_tab_open = false,
      }
    end
  }
    setup = 
  use {'yardnsm/vim-import-cost', run = 'yarn install' }
  use {'sindrets/diffview.nvim'}

  -- Objects
  use {'tpope/vim-surround'}                   -- Add surround object for editing
  -- use {'chaoren/vim-wordmotion'}            -- Treat words separated by undescores, case changing etc
  use {'wellle/targets.vim'}                   -- Add more targets for commands

  -- Improving functionalities
  use {'chrisbra/Recover.vim'}                 -- Show diff of a recovered or swap file
  use {'junegunn/vim-easy-align'}              -- Align stuff based on a symbol
  use {'christoomey/vim-tmux-navigator'}       -- Tmux splits integration
  use {'drzel/vim-split-line'}                 -- Split line at cursor
  use {'wincent/scalpel'}                      -- Replace word under cursor
  use {'machakann/vim-swap'}                   -- Swap delimited items
  use {'romainl/vim-cool'}                     -- Disable search highlighting on mode change
  use {'tpope/vim-repeat'}                     -- Repeat plugin mappings with .
  use {'norcalli/nvim-colorizer.lua'}          -- Show colors
  use {'justinmk/vim-sneak'}                   -- Adds a motion
  use {'christoomey/vim-sort-motion'}          -- Add sort motion
  use {'tpope/vim-eunuch'}                     -- Adds UNIX commands
  use {'machakann/vim-highlightedundo'}        -- Highlights undo region
  use {'tommcdo/vim-exchange'}                 -- Exchange two objects
  use {'tommcdo/vim-nowchangethat'}            -- Reapply previous change to a different object
  use {'farmergreg/vim-lastplace'}             -- Restore cursor position when reopening files
  use {'samirettali/shebang.nvim'}             -- Automatic shebang for new files
  use {'ojroques/vim-oscyank'}                 -- Copy in OS clipboard in SSH
  use {'rmagatti/auto-session'}                -- Continuously save session

  -- Colorscheme
  use {'bluz71/vim-moonfly-colors'}
  use {'NvChad/nvim-base16.lua'}

  -- Other
  use {'jez/vim-superman'}                     -- Use vman to read man inside vim
  use {'vuki656/package-info.nvim'}
  use {'nvim-telescope/telescope-symbols.nvim'}
  use {'nvim-treesitter/nvim-treesitter-textobjects'}
  use 'mfussenegger/nvim-dap'
  use {'theHamsta/nvim-dap-virtual-text'}
  use {'rcarriga/nvim-dap-ui',
    requires = {"mfussenegger/nvim-dap"}
  }
  use {'github/copilot.vim'}
  use {'rmagatti/goto-preview'}
  use 'catppuccin/nvim'

end)


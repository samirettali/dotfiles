local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
else
  vim.cmd [[packadd packer.nvim]]
end

vim.g.solarized_termcolors=256

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}

  -- Git
  use {'rhysd/committia.vim'}                  -- Better commit editing
  use {'tpope/vim-fugitive'}                   -- Git wrapper
  use {'f-person/git-blame.nvim'}              -- Show git blame
  use {'lewis6991/gitsigns.nvim'}              -- Show git diff in the gutter (requires plenary)

  -- Coding
  use {'windwp/nvim-autopairs'}                -- Autopair brackets and other symbols
  use {'b3nj5m1n/kommentary'}                  -- Commenting plugin
  use {'liuchengxu/vista.vim'}                 -- Show a panel to browse tags
  use {'alvan/vim-closetag'}                   -- Automatically close HTML tag
  -- use {'AndrewRadev/tagalong.vim'}             -- Automatically rename matching HTML tag
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install'}
  use {'omnisharp/omnisharp-vim'}

  -- Syntax highlighting
  use {'pantharshit00/vim-prisma'}             -- Prisma syntax
  use {'plasticboy/vim-markdown'}              -- Markdown
  use {'jparise/vim-graphql'}                  -- GraphQL syntax
  use {'dart-lang/dart-vim-plugin'}            -- Dart syntax
  use {'TovarishFin/vim-solidity'}
  -- use {'HerringtonDarkholme/yats.vim'}
  --[[ use {'othree/html5.vim'}
  use {'othree/yajs.vim'} ]]

  -- LSP and related
  use {'hrsh7th/nvim-compe'}                   -- Auto completion
  use {'neovim/nvim-lspconfig'}                -- LSP
  use {'glepnir/lspsaga.nvim'}                 -- LSP functions
  use {'nvim-treesitter/nvim-treesitter',
    branch = '0.5-compat',
    run = ':TSUpdate'
  }
  use {'nvim-treesitter/playground'}
  use {'onsails/lspkind-nvim'}

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
  use {'romgrk/barbar.nvim'}                   -- Buffers bar
  use {'hoob3rt/lualine.nvim'}                 -- Status line
  use {'mbbill/undotree'}                      -- Show a tree of undo history
  use {'mhinz/vim-startify'}                      -- Show a tree of undo history
  -- use {'dstein64/nvim-scrollview'}
  use {'lukas-reineke/indent-blankline.nvim'}  -- Show indent line
  use {'kyazdani42/nvim-tree.lua',             -- Tree navigation
    requires = {{
      'kyazdani42/nvim-web-devicons'
    }}
  }
  use {'yardnsm/vim-import-cost', run = 'yarn install' }

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
  use {'tpope/vim-obsession'}                  -- Continuously save session

  -- Other
  use {'jez/vim-superman'}                     -- Use vman to read man inside vim

  -- Colorscheme
  use {'bluz71/vim-moonfly-colors'}
  use {'drewtempelmeyer/palenight.vim'}
  use {'ChristianChiarulli/nvcode-color-schemes.vim'}
  use {'siduck76/nvim-base16.lua'}
end)

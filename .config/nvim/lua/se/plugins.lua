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

  use {'jremmen/vim-ripgrep'}                  -- Ripgrep integration
  -- use {'prettier/vim-prettier', run = 'yarn install'}
  use {'sbdchd/neoformat'}
    -- \ 'for': ['javascript', 'typescript', 'typescriptreact', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html']
    -- \ }
  
  -- Git
  -- use {'mhinz/vim-signify'}                    -- Show git diff in the gutter
  use {'lewis6991/gitsigns.nvim'}                    -- Show git diff in the gutter
  use {'rhysd/committia.vim'}                  -- Better commit editing
  use {'tpope/vim-fugitive'}                   -- Git wrapper
  use {'f-person/git-blame.nvim'}
  
  -- Coding
  use {'jiangmiao/auto-pairs'}                 -- Auto completion for quotes, brackets, etc.
  use {'sheerun/vim-polyglot'}                 -- Better syntax highlighting
  use {'fatih/vim-go'}                         -- Golang plugins
  use {'tpope/vim-commentary'}                 -- Commenting plugin
  use {'majutsushi/tagbar'}                    -- Show a panel to browse tags
  -- use {'Valloric/MatchTagAlways'}              -- Highlight matching HTML tag
  use {'plasticboy/vim-markdown'}              -- Markdown improving
  use {'AndrewRadev/tagalong.vim'}             -- Automatically rename matching HTML tag
  use {'kana/vim-textobj-user'}
  use {'kana/vim-textobj-indent'}
  
  -- Syntax highlighting
  use {'pantharshit00/vim-prisma'}             -- Prisma syntax
  use {'jparise/vim-graphql'}
  use {'HerringtonDarkholme/yats.vim'}
  use {'othree/html5.vim'}
  use {'othree/yajs.vim'}
  
  use {'nvim-lua/completion-nvim'}             -- Auto completion using LSP
  use {'neovim/nvim-lspconfig'}
  use {'RishabhRD/popfix', hook = 'make' }
  use {'RishabhRD/nvim-lsputils'}
  use {'nvim-lua/popup.nvim'}
  -- use {'nvim-lua/lsp_extensions.nvim'}
  use {'nvim-lua/plenary.nvim'}
  use {'hrsh7th/vim-vsnip'}
  use {'hrsh7th/vim-vsnip-integ'}
  use {'nvim-telescope/telescope.nvim'}
  -- use {'nvim-treesitter/nvim-treesitter'}, {'do': ':TSUpdate'}
  use {'nvim-treesitter/nvim-treesitter'}
  
  -- Improving vim's functionalities
  use {'bkad/CamelCaseMotion'}
  use {'chrisbra/Recover.vim'}                 -- Show diff of a recovered or swap file
  use {'junegunn/vim-easy-align'}              -- Align stuff based on a symbol
  -- use {'Yggdroot/indentLine'}
  use {'christoomey/vim-tmux-navigator'}       -- Tmux splits integration
  use {'drzel/vim-split-line'}                 -- Split line at cursor
  use {'wincent/scalpel'}                      -- Replace word under cursor
  use {'tpope/vim-surround'}                   -- Add surround object for editing
  use {'machakann/vim-swap'}                   -- Swap delimited items
  use {'machakann/vim-textobj-delimited'}      -- More delimiting object
  use {'romainl/vim-cool'}                     -- Disable search highlighting on mode change
  use {'tpope/vim-repeat'}                     -- Repeat plugin mappings with .
  use {'norcalli/nvim-colorizer.lua'}          -- Show colors
  use {'justinmk/vim-sneak'}                   -- Adds a motion
  use {'christoomey/vim-sort-motion'}          -- Add sort motion
  use {'tpope/vim-eunuch'}                     -- Adds UNIX commands
  use {'machakann/vim-highlightedundo'}        -- Highlights undo region
  use {'stefandtw/quickfix-reflector.vim'}
  use {'wellle/targets.vim'}                   -- Add more targets for commands
  use {'rbgrouleff/bclose.vim'}
  use {'francoiscabrol/ranger.vim'}
  use {'tommcdo/vim-exchange'}                 -- Exchange two objects
  use {'tommcdo/vim-nowchangethat'}            -- Reapply previous change to a different object
  use {'farmergreg/vim-lastplace'}             -- Restore cursor position when reopening files
  use {'mbbill/undotree'}                      -- Show a tree of undo history
  use {'samirettali/shebang.nvim'}             -- Show a tree of undo history
  use {'ojroques/vim-oscyank'}
  
  -- UI components
  use {'romgrk/barbar.nvim'}                  -- Buffers bar
  -- use {'akinsho/nvim-bufferline.lua'}                  -- Buffers bar
  use {'hoob3rt/lualine.nvim'}               -- Status line
  
  -- Tree navigator
  use {'kyazdani42/nvim-web-devicons'}
  use {'kyazdani42/nvim-tree.lua'}
  
  -- Vimwiki
  -- use {'vimwiki/vimwiki'}
  -- use {'michal-h21/vimwiki-sync'}
  
  -- use {'blueyed/vim-diminactive'
  
  -- Colorscheme
  use {'bluz71/vim-moonfly-colors'}
  use {'bluz71/vim-nightfly-guicolors'}
  use {'ajh17/Spacegray.vim'}
  use {'dneto/spacegray-lightline'}
  use {'chriskempson/base16-vim'}
  use {'KeitaNakamura/neodark.vim'}
  use {'challenger-deep-theme/vim', as = 'challenger-deep' }
  use {'ghifarit53/tokyonight-vim'}
end)

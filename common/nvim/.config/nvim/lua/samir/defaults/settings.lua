local INDENT = 2
local BUFFER = vim.bo
local GLOBAL = vim.o
local WINDOW = vim.wo

local options = {
  [BUFFER] = {
      expandtab = true,
      tabstop = INDENT,
      shiftwidth = INDENT,
      smartindent = true,
      softtabstop = INDENT,
      -- smarttab = true,
      -- autoindent  = true
      synmaxcol = 200,
      undofile = true,
      spelllang ='it,en_us',
      -- textwidth = 80
  },
  [GLOBAL] = {
      bg = 'dark',
      hidden = true,                   -- Enable modified buffers in background
      ignorecase = true,               -- Ignore case
      smartcase = true,                -- Don't ignore case with capitals
      joinspaces = false,              -- No double spaces with join after a dot
      scrolloff = 5,                   -- Lines of context
      sidescrolloff = 8,               -- Columns of context
      shiftround = true,               -- Round indent
      splitbelow = true,               -- Put new windows below current
      splitright = true,               -- Put new windows right of current
      termguicolors = true,            -- True color support
      wildmode = 'longest:full,full',  -- Command-line completion mode
      -- columns = 80,
      -- showmatch = true,
      confirm = true,
      wildignore = '*.swp,*.bak,*.pyc,*.class',
      listchars ='tab:»·,trail:·,nbsp:~,eol:¬', -- Characters to visualize instead of whitespaces
      lazyredraw = true,
      timeoutlen = 500,
      completeopt = 'menuone,noinsert,noselect',
      inccommand = 'split',
      undodir = "~/.local/share/nvim/undo",
      directory = "~/.local/share/nvim/swap",
      backupdir = "~/.local/share/nvim/swap"
      -- showbreak = true,
  },
  [WINDOW] = {
      cursorline = true,
      cursorcolumn = false,
      list = false,
      number = true,
      relativenumber = true,
      wrap = true,
      -- linebreak = true,
      cursorline = true,
      colorcolumn = '81'
  },
}

local function set_all(opts)
  for scope, args in pairs(opts) do
      for option, value in pairs(args) do
          scope[option] = value
      end
  end
end

vim.cmd[[ filetype plugin indent on ]]

vim.g.mapleader = ','
set_all(options)
vim.cmd 'colorscheme moonfly'
vim.cmd 'set shortmess+=c'
vim.cmd 'set formatoptions-=t'

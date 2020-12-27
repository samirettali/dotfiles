local INDENT = 2
local BUFFER = vim.bo
local GLOBAL = vim.o
local WINDOW = vim.wo

local options = {
  [BUFFER] = { -- b
      expandtab = true,
      tabstop = INDENT,
      shiftwidth = INDENT,
      smartindent = true,
      softtabstop = INDENT,
      -- smarttab = true,
      -- autoindent  = true
      synmaxcol = 200,
      undofile = true,
      spelllang='it,en_us'
  },
  [GLOBAL] = { -- o
      bg = 'dark',
      hidden = true,                   -- Enable modified buffers in background
      ignorecase = true,               -- Ignore case
      smartcase = true,                -- Don't ignore case with capitals
      joinspaces = false,              -- No double spaces with join after a dot
      scrolloff = 5,                  -- Lines of context
      sidescrolloff = 8 ,              -- Columns of context
      shiftround = true,               -- Round indent
      splitbelow = true,               -- Put new windows below current
      splitright = true,               -- Put new windows right of current
      termguicolors = true,            -- True color support
      wildmode = 'longest:full,full',  -- Command-line completion mode
      title = true,
      showmatch = true,
      confirm = true,
      -- undodir= '~/.config/nvim/undo',
      -- backupdir='~/.config/nvim/tmp',
      -- directory='~/.config/nvim/swap'
      wildignore = '*.swp,*.bak,*.pyc,*.class',
      listchars='tab:»·,trail:·,nbsp:~,eol:¬', -- Visualize tab, spaces and newlines'
      mouse='nv',
      lazyredraw = true,
      timeoutlen=500,
  },
  [WINDOW] = { -- w
      cursorline = true,
      cursorcolumn = false,
      list = false,
      number = true,
      relativenumber = true,
      wrap = false,
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

set_all(options)
vim.cmd 'colorscheme default'

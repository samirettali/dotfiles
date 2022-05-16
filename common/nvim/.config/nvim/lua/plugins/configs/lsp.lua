local lspconfig = require('lspconfig')
local lsp = vim.lsp
local handlers = lsp.handlers
local util = lspconfig.util
local map = vim.api.nvim_set_keymap

vim.g.completion_trigger_on_delete = 1
vim.g.lsp_document_highlight_enabled = 1

-- Hover doc popup
local pop_opts = { border = "rounded", max_width = 80 }
handlers["textDocument/hover"] = lsp.with(handlers.hover, pop_opts)
handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, pop_opts)

local function custom_attach(client)
  -- require('completion').on_attach(client)

  map('n', 'gR',         '<cmd>lua require("telescope.builtin").lsp_references()<CR>')
  map('n', 'dn',         '<cmd>lua vim.diagnostic.goto_next()<CR>')
  map('n', 'dp',         '<cmd>lua vim.diagnostic.goto_prev()<CR>')
  map('n', 'ds',         '<cmd>lua vim.diagnostic.get()<CR>')
  map('n', '<Leader>gw', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
  map('n', '<Leader>gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
  map('n', '<Leader>=',  '<cmd>lua vim.lsp.buf.formatting()<CR>')
  map('n', 'gu',         '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
  map('n', '<Leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
  map('n', '<Leader>fe', '<cmd>lua require("telescope.functions").diagnostics()<CR>')

  map('n', 'cd',         '<cmd>lua vim.diagnostic.get()<CR>')
  map('n', 'ga',         '<cmd>lua vim.lsp.buf.code_action()<CR>')
  map('n', 'rn',         '<cmd>lua vim.lsp.buf.rename()<CR>')

  map('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
  map('n', 'gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
  map('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
  map('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
  map('n', 'gs',         '<cmd>lua vim.lsp.buf.signature_help()<CR>')

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")

  local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  if filetype == 'rust' then
    vim.cmd [[autocmd BufWritePre <buffer> :lua format_rust()]]
    -- vim.cmd [[autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost <buffer> :lua require"lsp_extensions".inlay_hints{ prefix = ' » ', highlight = "Comment", enabled = {"TypeHint","ChainingHint", "ParameterHint"}}]]
  elseif filetype == 'go' then
    vim.cmd [[autocmd BufWritePre <buffer> lua goimports(1000)]]

    -- gopls requires a require to list workspace arguments.
    vim.cmd [[autocmd BufEnter,BufNewFile,BufRead <buffer> map <buffer> <leader>fs <cmd>lua require('telescope.builtin').lsp_workspace_symbols { query = vim.fn.input("Query: ") }<cr>]]
  end

  -- Show diagnostic on hover
  -- vim.cmd [[autocmd CursorHold <buffer> lua vim.diagnostics.get({ focusable = false })]]
  vim.cmd [[autocmd CursorHold <buffer> lua vim.diagnostic.get()]]

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        " autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

vim.fn.sign_define("LspDiagnosticsSignError", {text = "", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "i", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "!", texthl = "LspDiagnosticsSignHint"})


vim.api.nvim_exec([[
  autocmd BufWritePre *.ts lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting()

  autocmd BufWritePre *.js lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting()

  autocmd BufWritePre *.py lua vim.lsp.buf.formatting()
]], false)

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

capabilities.textDocument.completion.completionItem.snippetSupport = true

capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = (function()
                local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                table.sort(res)
                return res
            end)()
        }
    }
}

vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   require('lsp_extensions.workspace.diagnostic').handler, {
--     virtual_text = true,
--     signs = true,
--     underline = true,
--     update_in_insert = false,
--   }
-- )

local servers = {
  bashls = {},
  hls = {},
  tsserver = {},
  html = {},
  cssls = {},
  pylsp = {},
  sqls = {},
  clangd = {},
  java_language_server = {},
  gopls = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
    },
  },
  rust_analyzer = {
    ["rust-analyzer"] = {
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      cargo = {
        loadOutDirsFromCheck = true
      },
      procMacro = {
        enable = true
      },
      checkOnSave = {
        command = "clippy",
      },
      flags = {
        debounce_text_changes = 200,
      },
    }
  },
  solc = {
      solc = {
          cmd = {
              "solc",
              "--lsp"
          },
          filetypes = {
              "solidity"
          },
          root_dir = util.root_pattern(".git"),
      }
  }
}

for lsp, settings in pairs(servers) do
  lspconfig[lsp].setup {
    on_attach = custom_attach,
    -- filetypes = opts.filetypes,
    capabilities = capabilities,
    settings = settings,
    flags = {
      debounce_text_changes = 200,
    },
  }
end

local pid = vim.fn.getpid()
lspconfig.omnisharp.setup{
    cmd = { '/usr/bin/omnisharp', "--languageserver" , "--hostPID", tostring(pid) },
    root_dir = util.root_pattern(".csproj", ".sln"),
    on_attach = custom_attach,
    flags = {
      debounce_text_changes = 200,
    },
}

function goimports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit)
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end

  vim.lsp.buf.formatting()
end

function format_rust()
  local lineno = vim.api.nvim_win_get_cursor(0)
  vim.lsp.buf.formatting_sync(nil, 1000)
  vim.api.nvim_win_set_cursor(0, lineno)
end

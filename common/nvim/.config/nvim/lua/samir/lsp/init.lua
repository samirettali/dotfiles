local lspconfig = require('lspconfig')
local saga = require('lspsaga')

saga.init_lsp_saga()

vim.g.completion_trigger_on_delete = 1
vim.g.lsp_document_highlight_enabled = 1

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function custom_attach(client)
  map('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
  map('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
  map('n', 'gR',         '<cmd>lua require("telescope.builtin").lsp_references()<CR>')
  map('n', 'dn',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  map('n', 'dp',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', 'ds',         '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  map('n', '<Leader>gw', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
  map('n', '<Leader>gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
  map('n', '<Leader>=',  '<cmd>lua vim.lsp.buf.formatting()<CR>')
  map('n', 'gu',         '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
  map('n', '<Leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
  map('n', '<Leader>fe', '<cmd>lua require("telescope.functions").show_diagnostics()<CR>')

  map('n', 'cd', '<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>')
  map('n', 'ga', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>')
  map('n', 'gs', '<cmd>lua require("lspsaga.signaturehelp").signature_help()<CR>')
  map('n', 'rn', '<cmd>lua require("lspsaga.rename").rename()<CR>')
  map('n', 'gr', '<cmd>lua require("lspsaga.provider").lsp_finder()<CR>', { silent = true })
  map('n', 'gd', '<cmd>lua require("lspsaga.provider").preview_definition()<CR>')
  map('n', 'K',  '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>')
  map('n', '[e', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>')
  map('n', ']e', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>')

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=DarkMagenta guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
  }
)

vim.fn.sign_define("LspDiagnosticsSignError",
    {text = "", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
    {text = "", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
    {text = "i", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
    {text = "!", texthl = "LspDiagnosticsSignHint"})


vim.api.nvim_exec([[
  autocmd BufWritePre *.ts lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting()

  autocmd BufWritePre *.js lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting()

  autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.go lua goimports(1000)

  autocmd BufWritePre *.css lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.less lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.scss lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.rs lua vim.lsp.buf.formatting()
]], false)

local servers = {
  bashls = { filetypes = { 'bash' } },
  hls = { filetypes = { 'haskell' } },
  tsserver = {
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx'
    }
  },
  html = { filetypes = { 'html' } },
  -- gopls = { filetypes = { 'go', 'gomod' } },
  rls = { filetypes = { 'rust' } },
  cssls = { filetypes = { 'css' } },
  pyls = { filetypes = { 'python' } },
  sqls = { filetypes = { 'sql' } },
  clangd = { filetypes = { 'c', 'cpp', 'objc', 'objcpp' } },
}

for lsp, opts in pairs(servers) do
  lspconfig[lsp].setup {
    -- root_dir = lspconfig.util.root_pattern('.git', vim.fn.getcwd()),
    on_attach = custom_attach,
    filetypes = opts.filetypes,
    capabilities = capabilities,
  }
end

local pid = vim.fn.getpid()
lspconfig.omnisharp.setup{
    cmd = { '/usr/bin/omnisharp', "--languageserver" , "--hostPID", tostring(pid) };
}

lspconfig.gopls.setup{
	cmd = {'gopls'},
  filetypes = { 'go', 'gomod' },
	-- for postfix snippets and analyzers
	capabilities = capabilities,
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
    },
  },
	on_attach = custom_attach,
}

function goimports(timeoutms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result or next(result) == nil then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

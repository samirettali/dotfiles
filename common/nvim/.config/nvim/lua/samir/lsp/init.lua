local lspconfig = require('lspconfig')
local saga = require('lspsaga')

saga.init_lsp_saga()

vim.g.completion_trigger_on_delete = 1

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
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
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
  " autocmd BufWritePre *.ts lua vim.lsp.buf.formatting_sync(nil, 100)
  " autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting_sync(nil, 100)

  " autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
  " autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)

  autocmd BufWritePre *.css lua vim.lsp.buf.formatting_sync(nil, 100)
  autocmd BufWritePre *.less lua vim.lsp.buf.formatting_sync(nil, 100)
  autocmd BufWritePre *.scss lua vim.lsp.buf.formatting_sync(nil, 100)
  autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 100)
]], false)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local servers = {
  bashls = { filetypes = { 'bash' } },
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
  gopls = { filetypes = { 'go' } },
  rls = { filetypes = { 'rust' } },
  cssls = { filetypes = { 'css' } }
}

for lsp, opts in pairs(servers) do
  lspconfig[lsp].setup {
    -- root_dir = lspconfig.util.root_pattern('.git', vim.fn.getcwd()),
    on_attach = custom_attach,
    filetypes = opts.filetypes,
    capabilities = capabilities,
  }
end
